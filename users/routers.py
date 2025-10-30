from fastapi import APIRouter, status
from sqlalchemy import select, insert, delete
from common.db import engine
from users.models import users
from users.schemas import User, UserResponse

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/")
async def get_users():
    with engine.connect() as conn:
        result = conn.execute(select(users))
        rows = result.fetchall()
        return [dict(row._mapping) for row in rows]


@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_user(user: User):
    with engine.connect() as conn:
        existing = conn.execute(
            select(users).where(users.c.email == user.email)
        ).fetchone()

        if existing:
            return {
                "success": False,
                "message": "이미 존재하는 이메일입니다."
            }

        conn.execute(insert(users).values(**user.dict()))
        conn.commit()

        return {
            "success": True,
            "message": "사용자가 성공적으로 등록되었습니다.",
            "data": user.dict()
        }

@router.get("/{user_id}")
async def get_user_by_id(user_id: int):
    with engine.connect() as conn:
        result = conn.execute(
            select(users).where(users.c.user_id == user_id)
        ).fetchone()

        if not result:
            return {
                "success": False,
                "message": "해당 사용자를 찾을 수 없습니다."
            }

        return {
            "success": True,
            "message": "사용자 조회 성공",
            "data": dict(result._mapping)
        }


@router.delete("/{user_id}")
async def delete_user(user_id: int):
    with engine.connect() as conn:
        existing = conn.execute(
            select(users).where(users.c.user_id == user_id)
        ).fetchone()

        if not existing:
            return {
                "success": False,
                "message": "해당 사용자를 찾을 수 없습니다."
            }

        conn.execute(delete(users).where(users.c.user_id == user_id))
        conn.commit()

        return {
            "success": True,
            "message": f"사용자(ID={user_id})가 성공적으로 삭제되었습니다."
        }
