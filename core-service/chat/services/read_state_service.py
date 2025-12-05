from sqlalchemy import select, insert, update, func
from sqlalchemy.orm import Session
from chat.models import chat_read_state, chat_messages
import uuid
from datetime import datetime, timezone


def update_read_state(db: Session, *, room_id: str, user_id: str):
    # 읽음 기록이 있는지 조회
    stmt = select(chat_read_state).where(
        chat_read_state.c.room_id == room_id,
        chat_read_state.c.user_id == user_id
    )
    existing = db.execute(stmt).mappings().first()

    if existing:
        # 업데이트: 마지막 읽은 시간 갱신
        upd = (
            update(chat_read_state)
            .where(
                chat_read_state.c.room_id == room_id,
                chat_read_state.c.user_id == user_id
            )
            .values(last_read_at=func.now())
        )
        db.execute(upd)
    else:
        # 새로 생성
        ins = insert(chat_read_state).values(
            id=str(uuid.uuid4()),
            room_id=room_id,
            user_id=user_id,
            last_read_at=func.now()
        )
        db.execute(ins)

    db.commit()

def get_unread_count(db: Session, *, room_id: str, user_id: str):

    # last_read_at 조회
    stmt_read = select(chat_read_state.c.last_read_at).where(
        chat_read_state.c.room_id == room_id,
        chat_read_state.c.user_id == user_id
    )
    row = db.execute(stmt_read).mappings().first()

    if row and row.last_read_at:
        last_read_at = row.last_read_at
    else:
        # 읽음 기록이 없다 -> 무조건 처음부터 안 읽음
        last_read_at = datetime.fromtimestamp(0, tz=timezone.utc)  

    # unread 메시지 수 계산
    stmt_unread = (
        select(func.count())
        .select_from(chat_messages)
        .where(
            chat_messages.c.room_id == room_id,
            chat_messages.c.timestamp > last_read_at
        )
    )

    unread = db.execute(stmt_unread).scalar()
    return unread or 0