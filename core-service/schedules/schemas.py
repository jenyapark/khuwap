from pydantic import BaseModel
from datetime import datetime

class ScheduleCreate(BaseModel):
    user_id: str
    course_code: str

class ScheduleResponse(BaseModel):
    user_id: str
    course_code: str
    enrolled_at: datetime

    class Config:
        orm_mode = True

