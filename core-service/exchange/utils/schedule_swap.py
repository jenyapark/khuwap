from sqlalchemy import delete, insert, update
from schedules.models import schedules
from exchange.models import exchange, exchange_requests

def perform_course_swap(conn, requester_id: int, accepter_id: int, desired_course: str, current_course: str):
    """
    실제 교환 수행:
    - requester_id: 교환 요청자
    - accepter_id: 게시글 작성자
    - desired_course: 요청자가 제공한 과목 (작성자가 받을 과목)
    - current_course: 작성자가 제공한 과목 (요청자가 받을 과목)
    """

    # 요청자 → desired_course 제거, current_course 추가
    conn.execute(
        delete(schedules)
        .where((schedules.c.user_id == requester_id) & (schedules.c.course_code == desired_course))
    )
    conn.execute(
        insert(schedules).values(user_id=requester_id, course_code=current_course)
    )

    # 작성자 → current_course 제거, desired_course 추가
    conn.execute(
        delete(schedules)
        .where((schedules.c.user_id == accepter_id) & (schedules.c.course_code == current_course))
    )
    conn.execute(
        insert(schedules).values(user_id=accepter_id, course_code=desired_course)
    )

    # 게시글과 요청 상태 업데이트
    conn.execute(
        update(exchange)
        .where(exchange.c.current_course == current_course)
        .values(status="completed")
    )
    conn.execute(
        update(exchange_requests)
        .where(exchange_requests.c.requester_id == requester_id)
        .values(status="accepted")
    )
