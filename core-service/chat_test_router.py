# core-service/routers/chat_test_router.py
from fastapi import APIRouter, Body
from fastapi. encoders import jsonable_encoder

from pydantic import BaseModel
from common.responses import error_response, success_response
import requests

class MessagePayload(BaseModel):
    room_id: str
    sender_id: str
    content: str

router = APIRouter()

CHAT_SERVER_URL = "http://localhost:8001/chat/receive"

@router.post("/chat/send")
def send_message_to_chat_service(payload: MessagePayload):
    response = requests.post(CHAT_SERVER_URL, json=payload.dict())

    if response.status_code == 200:
        return success_response(
            message="메시지가 정상적으로 전송되었습니다.",
            data=response.json(),
            status_code=200
        )
    else:
        return error_response(
            message="채팅 서버 응답 오류",
            status_code=response.status_code
        )