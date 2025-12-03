from common.db import SessionLocal
from courses.models import courses
from datetime import time


def seed_courses():
    db = SessionLocal()
    course_list = [
  {
    "course_code": "CSE20300",
    "course_name": "컴퓨터구조",
    "professor": "김성태",
    "day_of_week": "화/목",
    "start_time": "16:30",
    "end_time": "17:45",
    "room": "B07",
    "credit": 3
  },
  {
    "course_code": "CSE20301",
    "course_name": "컴퓨터구조",
    "professor": "김정욱",
    "day_of_week": "화/목",
    "start_time": "10:30",
    "end_time": "11:45",
    "room": "전205",
    "credit": 3
  },
  {
    "course_code": "CSE20400",
    "course_name": "자료구조",
    "professor": "장대희",
    "day_of_week": "월/수",
    "start_time": "15:00",
    "end_time": "16:50",
    "room": "B07",
    "credit": 3
  },
  {
    "course_code": "CSE20401",
    "course_name": "자료구조",
    "professor": "박제만",
    "day_of_week": "월/수",
    "start_time": "10:00",
    "end_time": "11:50",
    "room": "전205",
    "credit": 3
  },
  {
    "course_code": "CSE20402",
    "course_name": "자료구조",
    "professor": "이상훈",
    "day_of_week": "금",
    "start_time": "12:00",
    "end_time": "15:50",
    "room": "전137",
    "credit": 3
  },
  {
    "course_code": "SWCON20100",
    "course_name": "오픈소스SW개발방법및도구",
    "professor": "이성원",
    "day_of_week": "화/목",
    "start_time": "17:00",
    "end_time": "18:15",
    "room": "전205",
    "credit": 3
  },
  {
    "course_code": "SWCON20700",
    "course_name": "수치해석프로그래밍",
    "professor": "조명아",
    "day_of_week": "화/목",
    "start_time": "12:00",
    "end_time": "13:15",
    "room": "전103",
    "credit": 3
  },
  {
    "course_code": "SWCON21100",
    "course_name": "게임프로그래밍입문",
    "professor": "오승재",
    "day_of_week": "화/목",
    "start_time": "13:00",
    "end_time": "14:50",
    "room": "B01",
    "credit": 3
  },
  {
    "course_code": "SWCON21200",
    "course_name": "게임엔진기초",
    "professor": "이대호",
    "day_of_week": "월/수",
    "start_time": "14:00",
    "end_time": "15:50",
    "room": "B06",
    "credit": 3
  },
  {
    "course_code": "SWCON22100",
    "course_name": "마이크로서비스프로그래밍",
    "professor": "이성원",
    "day_of_week": "월/수",
    "start_time": "17:00",
    "end_time": "18:50",
    "room": "B01",
    "credit": 3
  },
  {
    "course_code": "SWCON24200",
    "course_name": "융합연구2",
    "professor": "박제만",
    "day_of_week": "화",
    "start_time": "18:00",
    "end_time": "18:50",
    "room": "미정",
    "credit": 1
  },
  {
    "course_code": "SWCON25300",
    "course_name": "기계학습",
    "professor": "이원희",
    "day_of_week": "화/목",
    "start_time": "10:30",
    "end_time": "11:45",
    "room": "B01",
    "credit": 3
  },
  {
    "course_code": "SWCON25301",
    "course_name": "기계학습",
    "professor": "김휘용",
    "day_of_week": "화/목",
    "start_time": "15:00",
    "end_time": "16:15",
    "room": "B09",
    "credit": 3
  },
  {
    "course_code": "SWCON25302",
    "course_name": "기계학습",
    "professor": "최진우",
    "day_of_week": "화/목",
    "start_time": "13:30",
    "end_time": "14:45",
    "room": "B09",
    "credit": 3
  },
  {
    "course_code": "SWCON25600",
    "course_name": "데이터분석입문",
    "professor": "박제만",
    "day_of_week": "월/수",
    "start_time": "12:00",
    "end_time": "13:15",
    "room": "전103",
    "credit": 3
  },
  {
    "course_code": "SWCON30200",
    "course_name": "최신기술콜로키움2",
    "professor": "진성욱",
    "day_of_week": "금",
    "start_time": "10:00",
    "end_time": "11:50",
    "room": "전205",
    "credit": 2
  },
  {
    "course_code": "SWCON49200",
    "course_name": "풀스택서비스네트워킹",
    "professor": "이성원",
    "day_of_week": "화/목",
    "start_time": "15:00",
    "end_time": "16:15",
    "room": "전136",
    "credit": 3
  },
  {
    "course_code": "AI300300",
    "course_name": "자연언어학습",
    "professor": "성무진",
    "day_of_week": "화/목",
    "start_time": "10:30",
    "end_time": "11:45",
    "room": "전309",
    "credit": 3
  },
  {
    "course_code": "AI300800",
    "course_name": "설명및신뢰가능한AI",
    "professor": "김성태",
    "day_of_week": "화/목",
    "start_time": "13:30",
    "end_time": "14:45",
    "room": "B05",
    "credit": 3
  },
  {
    "course_code": "CSE30100",
    "course_name": "운영체제",
    "professor": "허선영",
    "day_of_week": "월/수",
    "start_time": "13:30",
    "end_time": "14:45",
    "room": "B01",
    "credit": 3
  },
  {
    "course_code": "CSE30101",
    "course_name": "운영체제",
    "professor": "손희승",
    "day_of_week": "월/수",
    "start_time": "10:30",
    "end_time": "11:45",
    "room": "B07",
    "credit": 3
  },
  {
    "course_code": "CSE30200",
    "course_name": "컴퓨터네트워크",
    "professor": "허의남",
    "day_of_week": "화/목",
    "start_time": "10:30",
    "end_time": "11:45",
    "room": "전103",
    "credit": 3
  },
  {
    "course_code": "CSE30201",
    "course_name": "컴퓨터네트워크",
    "professor": "유인태",
    "day_of_week": "월/수",
    "start_time": "13:30",
    "end_time": "14:45",
    "room": "전137",
    "credit": 3
  },
  {
    "course_code": "CSE30202",
    "course_name": "컴퓨터네트워크",
    "professor": "이성원",
    "day_of_week": "월/수",
    "start_time": "15:00",
    "end_time": "16:15",
    "room": "B01",
    "credit": 3
  },
  {
    "course_code": "CSE30203",
    "course_name": "컴퓨터네트워크",
    "professor": "김정윤",
    "day_of_week": "금",
    "start_time": "09:00",
    "end_time": "11:45",
    "room": "전136",
    "credit": 3
  },
  {
    "course_code": "CSE30400",
    "course_name": "알고리즘",
    "professor": "박철준",
    "day_of_week": "월/수",
    "start_time": "16:30",
    "end_time": "18:20",
    "room": "B09",
    "credit": 3
  },
  {
    "course_code": "CSE30401",
    "course_name": "알고리즘",
    "professor": "성무진",
    "day_of_week": "화/목",
    "start_time": "13:00",
    "end_time": "14:50",
    "room": "B07",
    "credit": 3
  },
  {
    "course_code": "CSE30500",
    "course_name": "데이터베이스",
    "professor": "이영구",
    "day_of_week": "월/수",
    "start_time": "15:00",
    "end_time": "16:15",
    "room": "전136",
    "credit": 3
  },
  {
    "course_code": "CSE30501",
    "course_name": "데이터베이스",
    "professor": "김태연",
    "day_of_week": "화/목",
    "start_time": "10:30",
    "end_time": "11:45",
    "room": "B09",
    "credit": 3
  },
  {
    "course_code": "CSE32700",
    "course_name": "소프트웨어공학",
    "professor": "허의남",
    "day_of_week": "화/목",
    "start_time": "15:00",
    "end_time": "16:15",
    "room": "B07",
    "credit": 3
  },
  {
    "course_code": "CSE32701",
    "course_name": "소프트웨어공학",
    "professor": "이신영",
    "day_of_week": "화/목",
    "start_time": "13:30",
    "end_time": "14:45",
    "room": "전220",
    "credit": 3
  },
  {
    "course_code": "CSE33100",
    "course_name": "딥러닝",
    "professor": "배성호",
    "day_of_week": "화/목",
    "start_time": "10:30",
    "end_time": "11:45",
    "room": "B07",
    "credit": 3
  },
  {
    "course_code": "CSE33101",
    "course_name": "딥러닝",
    "professor": "배성호",
    "day_of_week": "화/목",
    "start_time": "15:00",
    "end_time": "16:15",
    "room": "B01",
    "credit": 3
  },
  {
    "course_code": "CSE33400",
    "course_name": "SW스타트업프로젝트",
    "professor": "이동현",
    "day_of_week": "수",
    "start_time": "15:00",
    "end_time": "17:45",
    "room": "글405",
    "credit": 3
  },
  {
    "course_code": "CSE34000",
    "course_name": "실전기계학습",
    "professor": "배성호",
    "day_of_week": "금",
    "start_time": "09:00",
    "end_time": "11:45",
    "room": "B06",
    "credit": 3
  },
  {
    "course_code": "SWCON37000",
    "course_name": "풀스택서비스프로그래밍",
    "professor": "이성원",
    "day_of_week": "화/목",
    "start_time": "13:00",
    "end_time": "14:50",
    "room": "전137",
    "credit": 3
  },
  {
    "course_code": "SWCON42500",
    "course_name": "데이터사이언스및시각화",
    "professor": "이원희",
    "day_of_week": "화",
    "start_time": "13:00",
    "end_time": "14:50",
    "room": "전136",
    "credit": 3
  },
  {
    "course_code": "SWCON34200",
    "course_name": "융합연구4",
    "professor": "조명아",
    "day_of_week": "금",
    "start_time": "09:00",
    "end_time": "09:50",
    "room": "미정",
    "credit": 1
  },
  {
    "course_code": "SWCON31300",
    "course_name": "가상/증강현실이론및실습",
    "professor": "이신영",
    "day_of_week": "금",
    "start_time": "12:00",
    "end_time": "14:45",
    "room": "전103",
    "credit": 3
  },
  {
    "course_code": "SWCON31400",
    "course_name": "게임공학",
    "professor": "오승재",
    "day_of_week": "화/목",
    "start_time": "15:00",
    "end_time": "16:50",
    "room": "B06",
    "credit": 3
  },
  {
    "course_code": "SWCON33100",
    "course_name": "로봇프로그래밍",
    "professor": "황효석",
    "day_of_week": "월/수",
    "start_time": "13:30",
    "end_time": "14:45",
    "room": "B07",
    "credit": 3
  } 
]

    for data in course_list:
        existing = db.execute(
            courses.select().where(
                courses.c.course_code == data["course_code"]
            )
        ).fetchone()

        if existing:
            continue
        
        start_h, start_m = map(int, data["start_time"].split(":"))
        end_h, end_m = map(int, data["end_time"].split(":"))


        db.execute(
            courses.insert().values(
                course_code=data["course_code"],
                course_name=data["course_name"],
                professor=data["professor"],
                day_of_week=data["day_of_week"],
                start_time=time(start_h, start_m),
                end_time=time(end_h, end_m),
                room=data["room"],
                credit=data["credit"],
            )
        )


        

    db.commit()
    db.close()


if __name__ == "__main__":
    seed_courses()
