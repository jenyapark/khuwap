from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional

class Exchange(BaseModel):
    author_id: str = Field(..., description = "게시글 작성자(user_id)")
    current_course: str = Field(..., description = "현재 수강 중인 과목 코드")
    desired_course: str = Field(..., description = "교환 희망 과목 코드")
    status: Optional[str] = Field(default = "open", description = "게시글 상태")
    note: Optional[str] = Field(None, description = "추가 설명")

class ExchangeCreate(Exchange):
    pass

class ExchangeUpdate(BaseModel):
    note = Optional[str] = Field(None, description = "추가 설명 수정")

class ExchangeResponse(Exchange):
    post_id: str
    created_at: datetime

    class Config:
        orm_mode = True