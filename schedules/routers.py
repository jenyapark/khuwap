from fastapi import APIRouter, status
from sqlalchemy import select, insert, delete
from common.db import engine
from schedules.models import schedules
from schedules.schemas import ScheduleCreate, ScheduleResponse

router = APIRouter(prefix="/schedules", tags=["Schedules"])

@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_schedule(schedule: ScheduleCreate):
    with engine.connect() as conn:
        existing = conn.execute(
            select(schedules)
            .where(
                (schedules.c.user_id == schedule.user_id)
                & (schedules.c.course_code == schedule.course_code)
            )
        ).fetchone()

        if existing:
            return {
                "success": False,
                "message": "이미 해당 과목을 수강 중입니다."
            }

        conn.execute(insert(schedules).values(**schedule.dict()))
        conn.commit()

        return {
            "success": True,
            "message": "수강 신청이 완료되었습니다.",
            "data": schedule.dict()
        }

@router.get("/{user_id}")
async def get_user_schedules(user_id: str):
    with engine.connect() as conn:
        result = conn.execute(
            select(schedules).where(schedules.c.user_id == user_id)
        ).fetchall()

        if not result:
            return {
                "success": True,
                "message": "해당 사용자의 수강 내역이 없습니다.",
                "data": []
            }

        rows = [dict(row._mapping) for row in result]
        return {
            "success": True,
            "message": "수강 내역 조회 성공",
            "data": rows
        }

@router.delete("/{user_id}/{course_code}")
async def delete_schedule(user_id: str, course_code: str):
    with engine.connect() as conn:
        existing = conn.execute(
            select(schedules)
            .where(
                (schedules.c.user_id == user_id)
                & (schedules.c.course_code == course_code)
            )
        ).fetchone()

        if not existing:
            return {
                "success": False,
                "message": "해당 수강 내역을 찾을 수 없습니다."
            }

        conn.execute(
            delete(schedules)
            .where(
                (schedules.c.user_id == user_id)
                & (schedules.c.course_code == course_code)
            )
        )
        conn.commit()

        return {
            "success": True,
            "message": "수강 취소가 완료되었습니다."
        }

