from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional

class Exchange(BaseModel):
    author_id: str = Field(..., description = "게시글 작성자(user_id)")
    current_course: str = Field(..., description = "현재 수강 중인 과목 코드")
    desired_course: str = Field(..., description = "교환 희망 과목 코드")
    note: Optional[str] = Field(None, description = "추가 설명")

#게시글 등록용
class ExchangeCreate(Exchange):
    pass

#게시글 수정용
class ExchangeUpdate(BaseModel):
    note: Optional[str] = Field(None, description = "추가 설명 수정")

#교환 요청
class ExchangeRequestCreate(BaseModel):
    exchange_uuid: str = Field(..., description="게시글 UUID (post_uuid)")
    requester_id: str = Field(..., description="요청자(user_id)")

#요청 응답
class ExchangeRequestResponse(BaseModel):
    request_uuid: str = Field(..., description="요청 UUID (request_uuid)")
    exchange_post_uuid: str = Field(..., description="게시글 UUID (post_uuid)")
    requester_id: str = Field(..., description="요청자(user_id)")
    status: str = Field(..., description = "요청 상태")
    created_at: datetime

#게시글 조회
class ExchangeResponse(Exchange):
    post_id: int
    exchange_uuid: str
    created_at: datetime

    model_config = {"from_attributes": True}