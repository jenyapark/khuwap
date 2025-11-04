from fastapi import APIRouter, status
from fastapi.encoders import jsonable_encoder
from sqlalchemy import select, insert, delete, update
from common.db import engine
from common.responses import success_response, error_response
from users.models import users
from users.schemas import User, UserCreate

router = APIRouter(prefix="/users", tags=["users"])

#전체 사용자 조회
@router.get("/")
async def get_users():
    with engine.connect() as conn:
        result = conn.execute(select(users))
        rows = result.mappings().all()
        return success_response(
            data = jsonable_encoder(rows),
            message = "전체 사용자 목록이 조회되었습니다.",
            status_code = 200,
        )

#사용자 등록
@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_user(user: User):
    with engine.connect() as conn:
        existing = conn.execute(
            select(users).where(users.c.email == user.email)
        ).fetchone()

        if existing:
            return error_response(
                message = "이미 존재하는 이메일입니다.",
                status_code = 400
            )

        conn.execute(insert(users).values(**user.dict()))
        conn.commit()

        return success_response(
            data = user.model_dump(),
            message = "사용자가 성공적으로 등록되었습니다.",
            status_code = 201
        )

#특정 사용자 조회
@router.get("/{user_id}")
async def get_user_by_id(user_id: int):
    with engine.connect() as conn:
        result = conn.execute(
            select(users).where(users.c.user_id == user_id)
        ).fetchone()

        if not result:
            return error_response(
                message = "해당 사용자를 찾을 수 없습니다.",
                status_code = 404
            )

        return success_response(
            data = dict(result._mapping),
            message = "사용자 조회 성공",
            status_code = 200
        )

@router.put("/{user_id}")
async def update_user(user_id: str, user: UserCreate):
    with engine.connect() as conn:
        existing = conn.execute(
            select(users).where(users.c.user_id == user_id)
        ).fetchone()

        if not existing:
            return error_response(
                message = "해당 학번을 찾을 수 없습니다.",
                status_code = 404
            )
        
        conn.execute(
            update(users)
            .where(users.c.user_id == user_id)
            .values(**user.dict())
        )
        conn.commit()

        return success_response(
            data = user.dict(),
            message = "사용자 정보가 성공적으로 수정되었습니다."
        )

@router.delete("/{user_id}")
async def delete_user(user_id: int):
    with engine.connect() as conn:
        existing = conn.execute(
            select(users).where(users.c.user_id == user_id)
        ).fetchone()

        if not existing:
            return error_response(
                message = "해당 사용자를 찾을 수 없습니다.",
                status_code = 404
            )

        conn.execute(delete(users).where(users.c.user_id == user_id))
        conn.commit()

        return success_response(
            message = f"{user_id} 사용자가 성공적으로 삭제되었습니다."
        )
