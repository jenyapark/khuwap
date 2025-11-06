from datetime import time

def normalize_row(row):
    if isinstance(row, list):
        print(row, "list다아다다ㅏㅇ라머리머이ㅏㅁ")
        if not row:
            return {}
        row = row[0]
    print(row, "이제 좀 바뀌었니?")
    return {k.split(".")[-1]: v for k, v in row.items()}


def to_time(t_str: str) -> time:
    """'HH:MM' 문자열을 datetime.time 객체로 변환"""
    if isinstance(t_str, time):
        return t_str
    if isinstance(t_str, str):
        h, m = map(int, t_str.split(":"))
        return time(h, m)

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

    # 교환으로 바꿀 과목은 비교 대상에서 제외
    requester_filtered = [
        normalize_row(s)
        for s in requester_schedules
        if normalize_row(s).get("course_code") != requester_excluded_course
    ]
    accepter_filtered = [
        normalize_row(s)
        for s in accepter_schedules
        if normalize_row(s).get("course_code") != accepter_excluded_course
    ]

    def is_conflict(a, b):
        same_day = a["day_of_week"] == b["day_of_week"]
        if not same_day:
            return False
        start_a, end_a = to_time(a["start_time"]), to_time(a["end_time"])
        start_b, end_b = to_time(b["start_time"]), to_time(b["end_time"])
        return start_a < end_b and start_b < end_a

    # 실제 충돌 탐색
    for a in requester_filtered:
        for b in accepter_filtered:
            if is_conflict(a, b):
                return True
    return False