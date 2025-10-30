from pydantic import BaseModel
from datetime import time

class Course(BaseModel):
    course_code: str
    course_name: str
    professor: str | None = None
    day_of_week: str | None = None
    start_time: time | None = None
    end_time: time | None = None
    room: str | None = None
    credit: int | None = None

    class Config:
        orm_mode = True

class CourseCreate(Course):
    pass

class Course(Course):
    class Config:
        orm_mode = True
