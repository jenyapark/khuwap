# chat/routers/history.py
from fastapi import APIRouter
from sqlalchemy import select
from common.db import engine
from chat.models import chat_messages

router = APIRouter(prefix="/chat", tags=["Chat"])

@router.get("/history/{room_id}")
def get_chat_history(room_id: str):
    """
    특정 채팅방의 전체 메시지 내역을 시간순으로 조회합니다.
    """
    with engine.connect() as conn:
        messages = conn.execute(
            select(chat_messages)
            .where(chat_messages.c.room_id == room_id)
            .order_by(chat_messages.c.timestamp)
        ).mappings().all()

        history = [
            {
                "sender_id": msg["sender_id"],
                "content": msg["content"],
                "timestamp": msg["timestamp"].strftime("%Y-%m-%d %H:%M:%S"),
            }
            for msg in messages
        ]

    return {
        "room_id": room_id,
        "count": len(history),
        "messages": history,
    }
