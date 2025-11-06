from sqlalchemy import select, and_
from common.db import engine
from common.responses import error_response, success_response
from exchange.models import exchange, exchange_requests
from schedules.models import schedules
from courses.models import courses
from exchange.utils.schedule_conflict import check_time_conflict

def validate_requests_creation(requester_id: str, exchange_uuid: str):
    with engine.connect() as conn:

        #게시글 존재 여부 확인
        target_post = conn.execute(
            select(exchange).where(exchange.c.exchange_uuid == exchange_uuid)
        ).mappings().first()

        if not target_post:
            return False,"존재하지 않는 게시글입니다."
        
        #자기 자신에게 요청 금지
        if target_post["author_id"] == requester_id:
            return False, "자기 자신에게 교환 요청을 보낼 수 없습니다."
        
        #게시글 상태 확인
        if target_post["status"] != "open":
            return False, "요청을 보낼 수 없는 게시글 상태입니다."
        
        #요청자가 게시글 작성자의 desired_course를 듣고 있는지 확인
        desired_course_code = target_post["desired_course"]
        has_desired_course = conn.execute(
            select(schedules)
            .where(
                (schedules.c.user_id == requester_id)
                & (schedules.c.course_code == desired_course_code)
            )
        ).mappings().first()

        if not has_desired_course:
            return False, "요청자는 게시글 작성자가 희망하는 과목을 수강 중이어야 합니다."
        
        #중복 요청 방지
        existing_request = conn.execute(
            select(exchange_requests).where(
                (exchange_requests.c.exchange_post_uuid == exchange_uuid)
                & (exchange_requests.c.requester_id == requester_id)
                & (exchange_requests.c.status == "pending")
            )
        ).mappings().first()

        if existing_request:
            return False,"이미 해당 게시글에 교환 요청을 보냈습니다."
        
        #시간표 유효성 검증
        
        requester_schedules = conn.execute(
            select(courses.c.course_code,
                   courses.c.day_of_week,
                   courses.c.start_time,
                   courses.c.end_time
            )
            .join(schedules, courses.c.course_code == schedules.c.course_code)
            .where(schedules.c.user_id == requester_id)
        ).mappings().all()

        accepter_schedules = conn.execute(
            select(courses.c.course_code,
                   courses.c.day_of_week,
                   courses.c.start_time,
                   courses.c.end_time
            )
            .join(schedules, courses.c.course_code == schedules.c.course_code)
            .where(schedules.c.user_id == target_post["author_id"])
        ).mappings().all()

        current_course = target_post["current_course"]
        desired_course = target_post["desired_course"]

        if any(s["course_code"] == target_post["desired_course"] for s in requester_schedules):
            return False,"이미 수강 중인 과목입니다."
        
        desired_course = conn.execute(
            select(courses).where(courses.c.course_code == desired_course)
        ).mappings().first()

        if not desired_course:
            return False, "희망 과목 정보를 찾을 수 없습니다."
        
        current_course_data = conn.execute(
            select(courses).where(courses.c.course_code == target_post["current_course"])
        ).mappings().first()
        if not current_course_data:
            return False,"상대방 과목 정보를 찾을 수 없습니다."
        
        has_conflict = check_time_conflict(
            requester_schedules=requester_schedules,
            accepter_schedules=accepter_schedules,
            requester_excluded_course=desired_course,
            accepter_excluded_course=current_course
        )

        if has_conflict:
            return False, "교환 후 두 사람의 시간표가 겹칩니다."
        
        return True, "요청 생성 검증 통과"
    

def validate_request_acceptance(request_uuid: str, accepter_id: int, conn) -> dict:

    #요청 존재 여부 확인
    query = select(exchange_requests).where(
        exchange_requests.c.request_uuid == request_uuid
    )
    request_row = conn.execute(query).mappings().first()

    if not request_row:
        return False,"존재하지 않는 교환 요청입니다."
    
    #요청 상태 확인
    if request_row["status"] in ["accepted", "cancelled"]:
        return False, "이미 처리된 교환 요청입니다."
    
    #게시글 존재 및 작성자 일치 여부 확인
    post_query = select(exchange).where(
        exchange.c.exchange_uuid == request_row["exchange_post_uuid"]
    )
    exchange_post = conn.execute(post_query).mappings().first()

    if not exchange_post:
        return False, "연결된 교환 게시글을 찾을 수 없습니다."
    
    if exchange_post["author_id"] != accepter_id:
        return False,"게시글 작성자만 해당 요청을 수락할 수 있습니다."
    
    #게시글 open 여부 확인
    if exchange_post["status"] != "open":
        return False,"현재 수락할 수 없는 상태의 게시글입니다."
    
    #시간표 충돌 검증
    requester_id = request_row["requester_id"]

    requester_schedules = conn.execute(
        select(schedules).where(schedules.c.user_id == requester_id)
    ).mappings().all()

    accepter_schedules = conn.execute(
        select(schedules).where(schedules.c.user_id == accepter_id)
    ).mappings().all()

    has_conflict = check_time_conflict(
        requester_schedules=requester_schedules,
        accepter_schedules=accepter_schedules,
        requester_excluded_course=exchange_post["desired_course"],
        accepter_excluded_course=exchange_post["current_course"]
    )
    if has_conflict:
        return False,"교환 후 시간표가 서로 겹칩니다."
    
    #자기 자신 요청 여부 확인
    if requester_id == accepter_id:
        return False,"자기 자신에게 보낸 요청은 수락할 수 없습니다."
    
    #동일 게시글 중복 수락 방지
    accepted_exists_query = select(exchange_requests).where(
        (exchange_requests.c.exchange_post_uuid == request_row["exchange_post_uuid"]) &
        (exchange_requests.c.status == "accepted")
    )
    already_accepted = conn.execute(accepted_exists_query).mappings().first()

    if already_accepted:
        return False,"이미 다른 요청이 수락된 게시글입니다."
    
    return True, "교환 요청 수락 검증이 완료되었습니다."

    