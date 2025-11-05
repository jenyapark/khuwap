from sqlalchemy import select, and_
from common.responses import error_response, success_response
from exchange.models import exchange
from schedules.models import schedules
from courses.models import courses

def valiate_post_creation(user_id: str, current_course: str, desired_course: str, conn):
    
    has_current_course = conn.execute(
        select(schedules).where(
            and_(
                schedules.c.user_id == user_id,
                schedules.c.course_code == current_course
            )
        )
    ).first()

    if not has_current_course:
        return False, "현재 수강 중인 과목이 아닙니다."
    
    has_desired_course = conn.execute(
        select(schedules).where(
            and_(
                schedules.c.user_id == user_id,
                schedules.c.course_code == desired_course
            )
        )
    ).first()

    if has_desired_course:
        return False, "이미 해당 과목을 수강 중입니다."
    
    current_course_info = conn.execute(
        select(courses).where(courses.c.course_code == current_course)
    ).mappings().all()
    
    desired_course_info = conn.execute(
        select(courses).where(courses.c.course_code == desired_course)
    ).mappings().all()

    if not current_course_info or not desired_course_info:
        return False, "존재하지 않는 과목 코드입니다."

    
    user_courses = conn.execute(
        select(courses)
        .join(schedules, courses.c.course_code == schedules.c.course_code)
        .where(schedules.c.user_id == user_id)
    ).mappings().all()
    
    for uc in user_courses:
        same_day = uc["day_of_week"] == desired_course_info["day_of_week"]
        time_overlap = (
            uc["start_time"] < desired_course_info["end_time"]
            and uc["end_time"] > desired_course_info["start_time"]
        )
        if same_day and time_overlap:
            return False, "희망 과목이 기존 수강 과목과 시간이 겹칩니다."

    
    existing_post = conn.execute(
        select(exchange).where(
            and_(
                exchange.c.author_id == user_id,
                exchange.c.current_course == current_course
            )
        )
    ).first()

    if existing_post:
        return False, "이미 동일 과목으로 등록된 게시글이 존재합니다."
    
    return True, "게시글 생성 가능"