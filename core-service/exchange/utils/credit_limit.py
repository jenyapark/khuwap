from sqlalchemy import select, and_
from common.db import engine
from common.responses import error_response, success_response
from exchange.models import exchange, exchange_requests
from schedules.models import schedules
from courses.models import courses
from users.models import users
from exchange.utils.schedule_conflict import check_time_conflict



def check_credit_limit(conn, user_id: str, new_course_code: str | None = None, drop_course_code: str | None = None) -> tuple[bool, str]:
    """
    사용자의 최대 학점 초과 여부 검증.
    - new_course_code: 새로 추가할 과목 (시간표 등록 or 교환)
    - drop_course_code: 교환 시 교체될 과목
    """
    # 현재 수강 중 과목 학점 합
    query = (
        select(courses.c.credit)
        .join(schedules, schedules.c.course_code == courses.c.course_code)
        .where(schedules.c.user_id == user_id)
    )

    rows = conn.execute(query).mappings().all()
    total_credit = sum((r.get("credit") or 0) for r in rows)

    # 새 과목 추가 시
    if new_course_code:
        new_course_credit = conn.execute(
            select(courses.c.credit).where(courses.c.course_code == new_course_code)
        ).scalar_one_or_none() or 0

        total_credit += new_course_credit

    # 교환 시, 기존 과목 제거
    if drop_course_code:
        drop_course_credit = conn.execute(
            select(courses.c.credit).where(courses.c.course_code == drop_course_code)
        ).scalar_one_or_none() or 0

        total_credit -= drop_course_credit

    # 최대 학점 가져오기
    max_credit = conn.execute(
        select(users.c.max_credit).where(users.c.user_id == user_id)
    ).scalar_one_or_none() or 18 

    if total_credit > max_credit:
        return False, f"최대 수강 가능 학점({max_credit})을 초과합니다."
    
    return True, "학점 제한 검증 통과"
