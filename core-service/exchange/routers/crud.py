from fastapi import APIRouter, Depends, HTTPException
from fastapi.encoders import jsonable_encoder
from sqlalchemy import select, insert, update, delete
from common.db import engine
from common.responses import success_response, error_response
from exchange.models import exchange, exchange_requests
from exchange.schemas import ExchangeCreate, ExchangeUpdate, ExchangeResponse, ExchangeRequestCreate, ExchangeRequestResponse
from exchange.validators.post import valiate_post_creation

router = APIRouter(tags = ["exchange"])

#게시글 생성
@router.post("/", response_model = ExchangeResponse)
def create_exchange_post(payload: ExchangeCreate):
    with engine.connect() as conn:
        is_valid, message = valiate_post_creation(
            user_id=payload.author_id,
            current_course= payload.current_course,
            desired_course=payload.desired_course,
            conn=conn
        )
        if not is_valid:
            return error_response(message = message, status_code=400)
        
        new_post = payload.model_dump()
        result = conn.execute(
            insert(exchange).values(**new_post).returning(exchange)
        )
        conn.commit()
        created = result.mappings().first()

        if not created:
            return error_response(message="게시글 생성 실패", status_code = 500)
        
        return success_response(
            data = jsonable_encoder(created),
            message = "게시글이 성공적으로 등록되었습니다.",
            status_code = 201
        )

#전체 게시글 조회
@router.get("/list", response_model = list[ExchangeResponse])
def get_all_exchange_posts():
    with engine.connect() as conn:
        result = conn.execute(select(exchange))
        posts = result.mappings().all()
        
    return success_response(
        data = jsonable_encoder(posts),
        message = "모든 게시글 조회 성공",
        status_code = 200,
    )

#특정 게시글 조회
@router.get("/{post_uuid}", response_model = ExchangeResponse)
def get_exchange_post(post_uuid: str):
    with engine.connect() as conn:
        result = conn.execute(
            select(exchange).where(exchange.c.post_uuid == post_uuid)
        )
        post = result.mappings().first()
        
    if not post:
        return error_response( message = "게시글을 찾을 수 없습니다.", status_code = 404)
        
    return success_response(
        data = jsonable_encoder(post),
        message = "게시글 조회 성공",
        status_code = 200,
    )
    

#게시글 수정
@router.patch("/{post_uuid}", response_model = ExchangeResponse)
def update_exchange_post(post_uuid: str, payload: ExchangeUpdate):
    update_data = payload.model_dump(exclude_unset=True)
    if not update_data:
        return error_response(message = "수정할 내용이 없습니다.", status_code = 400)
    
    with engine.connect() as conn:
        existing = conn.execute(select(exchange).where(exchange.c.post_uuid == post_uuid)).mappings().first()
        
        if not existing:
            return error_response(message = "게시글을 찾을 수 없습니다.", status_code = 404)
        conn.execute(
                update(exchange).where(exchange.c.post_uuid == post_uuid).values(**update_data)
        )
        conn.commit()

        updated = conn.execute(select(exchange).where(exchange.c.post_uuid == post_uuid)).mappings().first()

    return success_response(
        data = jsonable_encoder(updated),
        message = "게시글 수정 완료",
        status_code = 200,
    )

#게시글 삭제
@router.delete("/{post_uuid}")
def delete_exchange_post(post_uuid: str):
    with engine.connect() as conn:
        existing = conn.execute(select(exchange).where(exchange.c.post_uuid == post_uuid)).mappings().first()

        if not existing:
            return error_response(message = "게시글을 찾을 수 없습니다.", status_code = 404)
            
        conn.execute(delete(exchange).where(exchange.c.post_uuid == post_uuid))
        conn.commit()
        
    return success_response(message = "게시글이 삭제되었습니다.", status_code=200)

# 내가 작성한 게시글 목록 조회
@router.get("/mylist/{user_id}")
def get_my_exchange_posts(user_id: str):
    with engine.connect() as conn:
        result = conn.execute(
            select(exchange)
            .where(exchange.c.author_id == user_id)
            .order_by(exchange.c.created_at.desc())
        )
        posts = result.mappings().all()

    # 작성된 글이 하나도 없는 경우
    if not posts:
        return success_response(
            data=[],
            message="작성한 게시글이 없습니다.",
            status_code=200
        )

    return success_response(
        data=jsonable_encoder(posts),
        message="내 교환글 목록 조회 성공",
        status_code=200
    )