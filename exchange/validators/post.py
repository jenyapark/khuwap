from sqlalchemy import select, and_
from common.responses import error_response, success_response
from exchange.models import exchange
from schedules.models import schedules
from courses.models import courses
from exchange.utils.schedule_conflict import check_time_conflict

def valiate_post_creation(user_id: str, current_course: str, desired_course: str, conn):
    
    #현재 수강 과목 여부 확인
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
    
    #희망 과목 중복 수강 금지
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
    
    #과목 코드 유효성 검증
    current_course_info = conn.execute(
        select(courses).where(courses.c.course_code == current_course)
    ).mappings().all()

    desired_course_info = conn.execute(
        select(courses.c.course_code.label("course_code"),
               courses.c.day_of_week.label("day_of_week"),
               courses.c.start_time.label("start_time"),
               courses.c.end_time.label("end_time")
               ).where(courses.c.course_code == desired_course)
    ).mappings().first()

    if not current_course_info or not desired_course_info:
        return False, "존재하지 않는 과목 코드입니다."

    user_schedules = conn.execute(
        select(
            schedules.c.user_id,
            schedules.c.course_code,
            courses.c.day_of_week,
            courses.c.start_time,
            courses.c.end_time
        )
        .join(courses, schedules.c.course_code == courses.c.course_code)
        .where(schedules.c.user_id == user_id)
    ).mappings().all()

    has_conflict = check_time_conflict(
        requester_schedules=[desired_course_info],
        accepter_schedules=user_schedules,
        requester_excluded_course=desired_course,
        accepter_excluded_course=current_course
    )

    if has_conflict:
        return False, "희망 과목이 기존 수강 과목과 시간이 겹칩니다."
    
    #동일 과목으로 등록된 게시글 중복 방지
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