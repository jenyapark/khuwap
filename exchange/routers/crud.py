from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, insert, update, delete
from common.db import engine
from common.responses import success_response, error_response
from exchange.models import exchange
from exchange.schemas import ExchangeCreate, ExchangeUpdate, ExchangeResponse

router = APIRouter(prefix="/exchange", tags = ["exchange"])

#게시글 생성
@router.post("/", response_model = ExchangeResponse)
def create_exchange_post(payload: ExchangeCreate):
    with engine.connect() as conn:
        new_post = payload.model_dump()
        result = conn.execute(
            insert(exchange).values(**new_post).returning(exchange)
        )
        conn.commit()
        created = result.mappings().first()

        if not created:
            return error_response(message="게시글 생성 실패", status_code = 500)
        
        return success_response(
            data = dict(created._mapping),
            message = "게시글이 성공적으로 등록되었습니다.",
            status_code = 201
        )

#전체 게시글 조회
@router.get("/", response_model = list[ExchangeResponse])
def get_all_exchange_posts():
    with engine.connect() as conn:
        result = conn.execute(select(exchange))
        posts = result.mappings().all()
        
    return success_response(
        data = posts,
        message = "모든 게시글 조회 성공",
        status_code = 200,
    )

#특정 게시글 조회
@router.get("/{post_id}", response_model = ExchangeResponse)
def get_exchange_post(post_id: str):
    with engine.connect() as conn:
        result = conn.execute(select(exchange).where(exchange.c.post_id == post_id))
        post = result.mappings().first()
        
    if not post:
        return error_response( message = "게시글을 찾을 수 없습니다.", status_code = 404)
        
    return success_response(
        data = post,
        message = "게시글 조회 성공",
        status_code = 200,
    )
    

#게시글 수정
@router.patch("/{post_id}", response_model = ExchangeResponse)
def update_exchange_post(post_id: str, payload: ExchangeUpdate):
    update_data = payload.dict(exclude_unset=True)
    if not update_data:
        return error_response(message = "수정할 내용이 없습니다.", status_code = 400)
    
    with engine.connect() as conn:
        existing = conn.execute(select(exchange).where(exchange.c.post_id == post_id)).mappings().first()
        
        if not existing:
            return error_response(message = "게시글을 찾을 수 없습니다.", status_code = 404)
        conn.execute(
                update(exchange).where(exchange.c.post_id) == post_id
        )
        conn.commit()

        updated = conn.execute(select(exchange).where(exchange.c.post_id == post_id)).mappings().first()

    return success_response(
        data = updated,
        message = "게시글 수정 완료",
        status_code = 200,
    )

#게시글 삭제
@router.delete("/{post_id}")
def delete_exchange_post(post_id: str):
    with engine.connect() as conn:
        existing = conn.execute(select(exchange).where(exchange.c.post_id == post_id)).mappings().first()

        if not existing:
            return error_response(message = "게시글을 찾을 수 없습니다.", status_code = 404)
            
        conn.execute(delete(exchange).where(exchange.c.post.id == post_id))
        conn.commit()
        
    return success_response(message = "게시글이 삭제되었습니다.", status_code=200)