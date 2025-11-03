from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select, insert, update, delete
from common.db import engine
from common.responses import success_response, error_response
from courses.models import courses
from courses.schemas import Course, CourseCreate

router = APIRouter(prefix="/courses", tags=["Courses"])

#전체 과목 조회
@router.get("/")
async def get_courses():
    with engine.connect() as conn:
        result = conn.execute(select(courses))
        rows = result.fetchall()
        return success_response(
            data = [dict(row._mapping) for row in rows],
            message = "전체 과목 목록이 조회되었습니다."
        )

#과목 등록
@router.post("/", status_code = status.HTTP_201_CREATED)
async def create_course(course: CourseCreate):
    with engine.connect() as conn:
        existing = conn.execute(
            select(courses).where(courses.c.course_code == course.course_code)
        ).fetchone()

        if existing:
            return error_response(
                message = "이미 존재하는 과목 코드입니다.",
                status_code = 400
            )
        
        conn.execute(insert(course).values(**course.dict()))
        conn.commit()

        return success_response(
            data = course.dict(),
            message = "과목이 정상적으로 등록되었습니다.",
            status_code = 201
        )

#과목 수정
@router.put("/{course_code}")
async def update_course(course_code: str, course: CourseCreate):
    with engine.connect() as conn:
    
        existing = conn.execute(
            select(courses).where(courses.c.course_code == course_code)
        ).fetchone()

        if not existing:
            return error_response(
                message = "해당 과목 코드를 찾을 수 없습니다.",
                status_code = 404
            )
        
        conn.execute(
            update(courses)
            .where(courses.c.course_code == course_code)
            .values(**course.dict())
        )
        conn.commit()


        return success_response(
            data = course.dict(),
            message = "과목 정보가 성공적으로 수정되었습니다."
        )


@router.delete("/{course_code}")
async def delete_course(course_code: str):
    with engine.connect() as conn:
        existing = conn.execute(
            select(courses).where(courses.c.course_code == course_code)
        ).fetchone()

        if not existing:
            return error_response(
                message = "해당 과목 코드를 찾을 수 없습니다.",
                status_code = 404
            )
        conn.execute(
            delete(courses).where(courses.c.course_code == course_code)
        )
        conn.commit()


        return success_response(
            message = f"{course_code} 과목이 정상적으로 삭제되었습니다."
        )