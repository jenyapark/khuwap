from fastapi import APIRouter, Depends, HTTPException
from fastapi.encoders import jsonable_encoder
from sqlalchemy import select, insert, update, delete
from common.db import engine
from common.responses import success_response, error_response
from exchange.models import exchange, exchange_requests
from exchange.schemas import ExchangeCreate, ExchangeUpdate, ExchangeResponse, ExchangeRequestCreate, ExchangeRequestResponse
from schedules.models import schedules

router = APIRouter(prefix="/exchange/request", tags=["exchange-request"])

#요청 생성
@router.post("/")
def create_exchange_request(payload: ExchangeRequestCreate):
    with engine.connect() as conn:

        #UUID로 교환 게시글 찾기
        target_post = conn.execute(
            select(exchange).where(exchange.c.exchange_uuid == payload.exchange_uuid)
        ).mappings().first()

        if not target_post:
            return error_response(message="존재하지 않는 게시글입니다.", status_code=404)
        
        #교환 요청 생성
        conn.execute(
            insert(exchange_requests).values(
                exchange_post_id = target_post["post_id"],
                exchange_post_uuid = payload.exchange_uuid,
                requester_id = payload.requester_id,
                status = "pending"
            )
        )

        #게시글 상태 업데이트
        conn.execute(
            update(exchange)
            .where(exchange.c.exchange_uuid == payload.exchange_uuid)
            .values(status="pending")
        )

        conn.commit()
    
    return success_response(
        message = "교환 요청이 전송되었습니다.",
        status_code=201,
        )

#교환 요청 취소
@router.delete("/sent/{request_id}")
def delete_exchange_request(request_id: int):
    with engine.connect() as conn:
        existing = conn.execute(
            select(exchange_requests).where(exchange_requests.c.request_id == request_id)
        ).mappings().first()

        if not existing:
            return error_response(message="요청을 찾을 수 없습니다.", status_code=404)
        
        conn.excute(
            delete(exchange_requests).where(exchange_requests.c.request_id == request_id)
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
        )
        requests = result.mappings().all()
    
    if not requests:
        return success_response(
            data = [],
            message="보낸 요청이 없습니다.",
            status_code=200,
        )
    return success_response(
        data = jsonable_encoder(requests),
        message = "보낸 요청 목록 조회 성공",
        status_code=200,
    )

#요청 수락
@router.patch("/{request_id}/accept")
def accept(request_id: int):
    with engine.connect() as conn:
        conn.execute(
            update(exchange_requests)
            .where(exchange_requests.c.request_id == request_id)
            .values(status="accepted")
        )

        conn.execute(
            update(exchange)
            .where(exchange.c.post_id == select(exchange_requests.c.exchange_post_id)
                   .where(exchange_requests.c.request_id == request_id)
                   .scalar_subquery())
            .values(status="completed")
        )

        conn.commit()

    return success_response(
        message="교환 요청이 수락되었습니다.",
        status_code=200,
    )