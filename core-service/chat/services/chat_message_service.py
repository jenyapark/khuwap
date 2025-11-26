from sqlalchemy.orm import Session
from sqlalchemy import select, insert
from datetime import datetime
import uuid

from chat.models import chat_messages   


# 메시지 저장
def save_message(
    db: Session,
    *,
    room_id: str,
    sender_id: str,
    content: str,
):
    message_id = str(uuid.uuid4())

    db.execute(
        insert(chat_messages).values(
            message_id=message_id,
            room_id=room_id,
            sender_id=sender_id,
            content=content,
            timestamp=datetime.now(),
        )
    )
    db.commit()

    return message_id


# 메시지 목록 조회
def get_messages_by_room(
    db: Session,
    *,
    room_id: str,
):
    stmt = (
        select(chat_messages)
        .where(chat_messages.c.room_id == room_id)
        .order_by(chat_messages.c.timestamp.asc())
    )

    rows = db.execute(stmt).fetchall()
    return rows
