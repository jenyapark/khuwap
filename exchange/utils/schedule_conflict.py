from datetime import time
from sqlalchemy.engine import RowMapping

def normalize_row(row):
    if isinstance(row, list):
        if not row:
            return {}
        row = row[0]
    return {k.split(".")[-1]: v for k, v in row.items()}


def to_time(t_str: str) -> time:
    """'HH:MM' 문자열을 datetime.time 객체로 변환"""
    if isinstance(t_str, time):
        return t_str
    if isinstance(t_str, str):
        h, m = map(int, t_str.split(":"))
        return time(h, m)
    
def is_conflict(a, b):
    a = normalize_row(a)
    b = normalize_row(b)


    same_day = a["day_of_week"] == b["day_of_week"]
    if not same_day:
            return False
    start_a, end_a = to_time(a["start_time"]), to_time(a["end_time"])
    start_b, end_b = to_time(b["start_time"]), to_time(b["end_time"])
    if start_a==start_b and end_a==end_b:
            return False
    if start_a < end_b and start_b < end_a:
            print(start_a, start_b)
            print(end_a, end_b)
            return True
    return False


def check_time_conflict(
    requester_schedules: list[dict],
    accepter_schedules: list[dict],
    requester_excluded_course: str,
    accepter_excluded_course: str
) -> bool:
    """
    두 사용자의 시간표가 교환 후 충돌하는지 확인.
    - requester_excluded_course: 요청자가 교환으로 '제거할' 과목
    - accepter_excluded_course: 작성자가 교환으로 '제거할' 과목
    """
    if isinstance(requester_excluded_course, RowMapping):
        requester_code = requester_excluded_course["course_code"]
    else:
        requester_code = requester_excluded_course




    # 1️⃣ 타입 맞춰서 course_code 추출 (dict or str)

    if isinstance(accepter_excluded_course, RowMapping):
        accepter_code = accepter_excluded_course["course_code"]
    else:
        accepter_code = accepter_excluded_course


    # 2️⃣ 교환으로 제외할 과목 제거
    requester_filtered = [
        s for s in requester_schedules if s.get("course_code") != requester_code
    ]
    accepter_filtered = [
        s for s in accepter_schedules if s.get("course_code") != accepter_code
    ]

    # 3️⃣ 교환 대상 과목 찾기
    requester_course = next(
        (s for s in requester_schedules if s.get("course_code") == requester_code),
        None,
    )
    accepter_course = next(
        (s for s in accepter_schedules if s.get("course_code") == accepter_code),
        None,
    )

    # 4️⃣ 요청자 입장: 작성자의 과목 추가했을 때 충돌 검사
    for s in requester_filtered:
        if is_conflict(s, accepter_course):
            print("[Conflict requester]", s, accepter_course)
            return True

    # 5️⃣ 작성자 입장: 요청자의 과목 추가했을 때 충돌 검사
    for s in accepter_filtered:
        if is_conflict(s, requester_course):
            print("[Conflict accepter]", s, requester_course)
            return True

    return False
