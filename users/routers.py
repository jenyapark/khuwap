from fastapi import APIRouter, status
from fastapi.encoders import jsonable_encoder
from sqlalchemy import select, insert, delete, update
from common.db import engine
from common.responses import success_response, error_response
from users.models import users
from users.schemas import User, UserCreate, UserLogin


router = APIRouter(tags=["users"])

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
@router.post("/register")
def create_user(user: User):
    with engine.connect() as conn:
        existing_user_id = conn.execute(
            select(users).where(users.c.user_id == user.user_id)
        ).fetchone()

        if existing_user_id:
            return error_response(
                message = "이미 가입된 학번입니다.",
                status_code = 400
            )
            
        existing = conn.execute(
            select(users).where(users.c.email == user.email)
        ).fetchone()

        if existing:
            return error_response(
                message = "이미 존재하는 이메일입니다.",
                status_code = 400
            )

        conn.execute(insert(users).values(**user.model_dump()))
        conn.commit()

        return success_response(
            data = user.model_dump(),
            message = "사용자가 성공적으로 등록되었습니다.",
            status_code = 201
        )

#특정 사용자 조회
@router.get("/{user_id}")
async def get_user_by_id(user_id: str):
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
            data = jsonable_encoder(result._mapping),
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
            data = user.model_dump(),
            message = "사용자 정보가 성공적으로 수정되었습니다."
        )

@router.delete("/{user_id}")
async def delete_user(user_id: str):
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
    
# 사용자 로그인
@router.post("/login")
def login_user(user: UserLogin):
    with engine.connect() as conn:
        # 이메일로 사용자 검색
        existing_user = conn.execute(
            select(users).where(users.c.email == user.email)
        ).fetchone()

        if not existing_user:
            return error_response(
                message="등록되지 않은 이메일입니다.",
                status_code=401
            )

        # 비밀번호 일치 확인
        if existing_user.password != user.password:
            return error_response(
                message="비밀번호가 올바르지 않습니다.",
                status_code=401
            )

        # 로그인 성공 → 유저 데이터 반환
        return success_response(
            data={
                "user_id": existing_user.user_id,
                "username": existing_user.username,
                "email": existing_user.email,
            },
            message="로그인 성공",
            status_code=200
        )

