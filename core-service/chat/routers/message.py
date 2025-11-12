from fastapi import APIRouter
from sqlalchemy import insert, select
from datetime import datetime
from uuid import uuid4
from pydantic import BaseModel
from chat.schemas import MessageCreate
from common.responses import error_response, success_response
from chat.utils.moderation import contains_profanity

from common.db import engine
from chat.models import chat_rooms, chat_messages

router = APIRouter(prefix="/chat", tags=["Chat"])

@router.post("/send")
def send_message(payload: MessageCreate):
    with engine.connect() as conn:
        # 1️⃣ 채팅방 존재 확인
        room = conn.execute(
            select(chat_rooms).where(chat_rooms.c.room_id == payload.room_id)
        ).mappings().first()
        if not room:
            return error_response(
                message="존재하지 않는 채팅방입니다."
            )
        
        if room["is_confirmed"]:
            return error_response(
                message="이 교환은 이미 수락되어 채팅이 종료되었습니다."
            )
        
        if contains_profanity(payload.content):
            return error_response(
                message="부적절한 표현이 포함되어 전송이 차단되었습니다."
            )

        # 2️⃣ 메시지 저장
        conn.execute(
            insert(chat_messages).values(
                message_id=str(uuid4()),
                room_id=payload.room_id,
                sender_id=payload.sender_id,
                content=payload.content,
                timestamp=datetime.utcnow(),
            )
        )
        conn.commit()

    return success_response(
        message="메시지 전송 완료",
        data= {
        "room_id": payload.room_id,
        "sender": payload.sender_id,
        "content": payload.content,
        }
    )


@router.get("/history/{room_id}")
def get_chat_history(room_id: str):
    with engine.connect() as conn:
        messages = conn.execute(
            select(chat_messages)
            .where(chat_messages.c.room_id == room_id)
            .order_by(chat_messages.c.timestamp)
        ).mappings().all()

        history = [
            {
                "sender_id": m["sender_id"],
                "content": m["content"],
                "timestamp": m["timestamp"].strftime("%Y-%m-%d %H:%M:%S"),
            }
            for m in messages
        ]
    return {"room_id": room_id, "messages": history}
