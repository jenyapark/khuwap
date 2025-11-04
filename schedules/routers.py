from fastapi import APIRouter, status
from fastapi.encoders import jsonable_encoder
from sqlalchemy import select, insert, delete, update, and_
from common.db import engine
from common.responses import success_response, error_response
from schedules.models import schedules
from schedules.schemas import ScheduleCreate
from users.models import users
from courses.models import courses

router = APIRouter(prefix="/schedules", tags=["schedules"])

#수강 등록(유저 존재 확인 -> 과목 존재 확인 -> 중복 수강 확인 -> 정상 등록)
@router.post("/")
def create_schedule(schedule: ScheduleCreate):
    with engine.connect() as conn:
        user_exists = conn.execute(
            select(users)
            .where(users.c.user_id == schedule.user_id)
        ).fetchone()

        if not user_exists:
            return error_response(
                message = "존재하지 않는 사용자입니다.",
                status_code = 404
            )
        
        course_exists = conn.execute(
            select(courses)
            .where(courses.c.course_code == schedule.course_code)
        ).fetchone()

        if not course_exists:
            return error_response(
                message = "존재하지 않는 과목 코드입니다.",
                status_code = 404
            )
        
        existing = conn.execute(
            select(schedules).where(
                and_(
                    schedules.c.user_id == schedule.user_id,
                    schedules.c.course_code == schedule.course_code
                )
            )
        ).fetchone()

        if existing:
            return error_response(
                message = "이미 해당 과목을 수강 중입니다.",
                status_code = 409
            )
        

        conn.execute(insert(schedules).values(**schedule.dict()))
        conn.commit()

        return success_response(
            data = schedule.dict(),
            message = "수강 신청이 완료되었습니다.",
            status_code = 201
        )

#사용자별 수강 내역 조회
@router.get("/{user_id}", status_code = status.HTTP_200_OK)
def get_user_schedules(user_id: str):
    with engine.connect() as conn:
        result = conn.execute(
            select(schedules).where(schedules.c.user_id == user_id)
        )

        if not result:
            return success_response(
                data = [],
                message = "해당 사용자의 수강 내역이 없습니다."
            )

        rows = result.mappings().all()
        return success_response(
            data = jsonable_encoder(rows),
            message = "수강 내역 조회 성공"
        )

#수강 취소
@router.delete("/{user_id}/{course_code}")
def delete_schedule(user_id: str, course_code: str):
    with engine.connect() as conn:
        existing = conn.execute(
            select(schedules).where(
                and_(
                    schedules.c.user_id == user_id,
                    schedules.c.course_code == course_code
                )
            )
        ).fetchone()

        if not existing:
            return error_response(
                message = "해당 수강 내역을 찾을 수 없습니다.",
                status_code = 404
            )

        conn.execute(
            delete(schedules)
            .where(
                (schedules.c.user_id == user_id)
                & (schedules.c.course_code == course_code)
            )
        )
        conn.commit()

        return success_response(
            message = "수강 취소가 완료되었습니다.",
            status_code = 200
        )
        

