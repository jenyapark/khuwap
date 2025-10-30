from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select, insert, update, delete
from common.db import engine
from courses.models import courses
from courses.schemas import Course, CourseCreate

router = APIRouter(prefix="/courses", tags=["Courses"])

@router.get("/")
async def get_courses():
    with engine.connect() as conn:
        result = conn.execute(select(courses))
        rows = result.fetchall()
        return [dict(row._mapping) for row in rows]


@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_course(course: CourseCreate):
    with engine.connect() as conn:
        existing = conn.execute(
	    select(courses).where(courses.c.course_code == course.course_code)
        ).fetchone()

        if existing:
            return {
	        "success": False,
	        "meassage": "이미 존재하는 과목 코드입니다."
            }

        conn.execute(insert(courses).values(**course.dict()))
        conn.commit()

        return {
            "success": True,
            "message": "과목이 정상적으로 등록되었습니다.",
            "data": course.dict()
        }

@router.put("/{course_code}")
async def update_course(course_code: str, course: CourseCreate):
    with engine.connect() as conn:
    
        existing = conn.execute(
            select(courses).where(courses.c.course_code == course_code)
        ).fetchone()

        if not existing:
            return {
                "success": False,
                "message": "해당 과목 코드를 찾을 수 없습니다."
            }

        
        conn.execute(
            update(courses)
            .where(courses.c.course_code == course_code)
            .values(**course.dict())
        )
        conn.commit()

        return {
            "success": True,
            "message": "과목 정보가 성공적으로 수정되었습니다.",
            "data": course.dict()
        }


@router.delete("/{course_code}")
async def delete_course(course_code: str):
    with engine.connect() as conn:
        
        existing = conn.execute(
            select(courses).where(courses.c.course_code == course_code)
        ).fetchone()

        if not existing:
            return {
                "success": False,
                "message": "해당 과목 코드를 찾을 수 없습니다."
            }
       
        conn.execute(
            delete(courses).where(courses.c.course_code == course_code)
        )
        conn.commit()

        return {
            "success": True,
            "message": f"{course_code} 과목이 정상적으로 삭제되었습니다."
        }

