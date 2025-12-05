from fastapi import APIRouter
from fastapi.encoders import jsonable_encoder
from sqlalchemy import select, insert, update, delete
from common.db import engine
from common.responses import success_response, error_response
from exchange.models import exchange, exchange_requests
from exchange.schemas import ExchangeCreate, ExchangeUpdate, ExchangeResponse, ExchangeRequestCreate, ExchangeRequestResponse
from exchange.validators.request import validate_requests_creation, validate_request_acceptance
from schedules.models import schedules
from exchange.utils.schedule_swap import perform_course_swap
from chat.models import chat_rooms
from uuid import uuid4
from datetime import datetime
import requests

router = APIRouter(tags=["exchange-request"])
CHAT_SERVICE_URL = "http://localhost:8080"

#요청 생성
@router.post("/")
def create_exchange_request(payload: ExchangeRequestCreate):

    is_valid, message = validate_requests_creation(
        requester_id=payload.requester_id,
        post_uuid=payload.post_uuid
    )

    if not is_valid:
        return error_response(
            message="요청 생성 검사 실패: "+ message,
            status_code=400,
        )

    with engine.connect() as conn:

        target_post = conn.execute(
            select(exchange.c.post_id, exchange.c.author_id)
            .where(exchange.c.post_uuid == payload.post_uuid)
        ).mappings().first()

        if not target_post:
            return error_response("존재하지 않는 게시글입니다.", 404)

        #교환 요청 생성
        result = conn.execute(
            insert(exchange_requests).values(
                exchange_post_id = target_post["post_id"],
                post_uuid = payload.post_uuid,
                requester_id = payload.requester_id,
                status = "pending"
            )
            .returning(exchange_requests.c.request_uuid)
        )

        created = result.mappings().first()

        #게시글 상태 업데이트
        conn.execute(
            update(exchange)
            .where(exchange.c.post_uuid == payload.post_uuid)
            .values(status="pending")
        )

        conn.commit()

    
    return success_response(
        message = "교환 요청이 전송되었습니다.",
        data = {"request_uuid": created["request_uuid"]},
        status_code=201,
    )

#교환 요청 취소
@router.delete("/sent/{request_uuid}")
def delete_exchange_request(request_uuid: str):
    with engine.connect() as conn:
        
        existing = conn.execute(
            select(exchange_requests).where(exchange_requests.c.request_uuid == request_uuid)
        ).mappings().first()

        if not existing:
            return error_response(message="요청을 찾을 수 없습니다.", status_code=404)
        
        post_uuid = existing["post_uuid"]

        conn.execute(
            delete(exchange_requests)
            .where(exchange_requests.c.request_uuid == request_uuid)
        )

        remaining_requests = conn.execute(
            select(exchange_requests)
            .where(
                (exchange_requests.c.post_uuid == post_uuid)
                & (exchange_requests.c.status == "pending")
            )
        ).mappings().all()

        if not remaining_requests:
            conn.execute(
                update(exchange)
                .where(exchange.c.post_uuid == post_uuid)
                .values(status="open")
            )
        conn.commit()

    return success_response(message="교환 요청이 취소되었습니다.", status_code=200)

#교환 요청 목록 보기
@router.get("/sent/{user_id}")
def get_sent_requests(user_id: str):
    with engine.connect() as conn:
        result = conn.execute(
            select(exchange_requests)
            .where(exchange_requests.c.requester_id == user_id)
            .order_by(exchange_requests.c.created_at.desc())
        ).mappings().all()
    
    if not result:
        return success_response(
            data = [],
            message="보낸 요청이 없습니다.",
            status_code=200,
        )
    return success_response(
        data = jsonable_encoder(result),
        message = "보낸 요청 목록 조회 성공",
        status_code=200,
    )

@router.get("/list/{post_uuid}")
def list_requests(post_uuid: str):
    with engine.connect() as conn:
        rows = conn.execute(
            select(exchange_requests)
            .where(exchange_requests.c.post_uuid == post_uuid)
        ).mappings().all()

        return rows 


#요청 수락
@router.patch("/{request_uuid}/accept")
def accept(request_uuid: str):
    with engine.connect() as conn:

        #요청 존재 여부
        request_row = conn.execute(
            select(exchange_requests)
            .where(exchange_requests.c.request_uuid == request_uuid)
        ).mappings().first()

        if not request_row:
            return error_response("존재하지 않는 교환 요청입니다.", 404)
    
        # 게시글 조회
        exchange_post = conn.execute(
            select(exchange).where(exchange.c.post_uuid == request_row["post_uuid"])
        ).mappings().first()

        if not exchange_post:
            return error_response("연결된 교환 게시글을 찾을 수 없습니다.", 404)

        accepter_id = exchange_post["author_id"]

        is_valid, msg = validate_request_acceptance(request_uuid, accepter_id, conn)
        if not is_valid:
            return error_response(msg)
        
        requester_id = request_row["requester_id"]
        desired_course = exchange_post["desired_course"]
        current_course = exchange_post["current_course"]

        perform_course_swap(
            conn=conn,
            requester_id=requester_id,
            accepter_id=accepter_id,
            desired_course=desired_course,
            current_course=current_course,
        )


        conn.execute(
            update(exchange_requests)
            .where(exchange_requests.c.request_uuid == request_uuid)
            .values(status="accepted")
        )

        conn.execute(
            update(exchange)
            .where(exchange.c.post_id == exchange_post["post_id"])
            .values(status="completed")
        )

        conn.commit()

    return success_response(
        message="교환 요청이 수락되었습니다.",
        status_code=200,
        data={
            "exchange_status": "completed",
        },
    )