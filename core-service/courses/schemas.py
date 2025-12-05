from pydantic import BaseModel
from datetime import time

class Course(BaseModel):
    course_code: str
    course_name: str
    professor: str
    day_of_week: str
    start_time: time
    end_time: time
    room: str
    credit: int


class CourseCreate(Course):
    pass

class CourseRead(Course):
    class Config:
        orm_mode = True
