from sqlalchemy.orm import Session
from sqlalchemy import select, and_, insert, update
from datetime import datetime
import uuid

from chat.models import chat_rooms 


# 방 조회 또는 생성
def get_or_create_chat_room(
    db: Session,
    *,
    post_uuid: str,
    author_id: str,
    peer_id: str,
):
    # 이미 있는지 조회
    stmt = (
        select(chat_rooms)
        .where(
            and_(
                chat_rooms.c.post_uuid == post_uuid,
                chat_rooms.c.author_id == author_id,
                chat_rooms.c.peer_id == peer_id,
            )
        )
        .limit(1)
    )
    row = db.execute(stmt).fetchone()
    if row:
        return row

    # 방 없으면 생성
    room_id = str(uuid.uuid4())

    db.execute(
        insert(chat_rooms).values(
            room_id=room_id,
            post_uuid=post_uuid,
            author_id=author_id,
            peer_id=peer_id,
            last_message="",
        )
    )
    db.commit()

    # 다시 조회해서 반환
    stmt = select(chat_rooms).where(chat_rooms.c.room_id == room_id)
    row = db.execute(stmt).fetchone()
    return row


# 방의 last_message / updated_at 업데이트
def update_chat_room_last_message(
    db: Session,
    *,
    room_id: str,
    last_message: str,
):
    db.execute(
        update(chat_rooms)
        .where(chat_rooms.c.room_id == room_id)
        .values(
            last_message=last_message,
            updated_at=datetime.utcnow(),
        )
    )
    db.commit()


# 내가 참여한 채팅방 목록 조회
def get_my_chat_rooms(db: Session, user_id: str):
    stmt = (
        select(chat_rooms)
        .where(
            (chat_rooms.c.author_id == user_id) |
            (chat_rooms.c.peer_id == user_id)
        )
        .order_by(chat_rooms.c.updated_at.desc())
    )

    rows = db.execute(stmt).fetchall()
    return rows


# 특정 채팅방 조회 (post_uuid + peer_id)
def get_room_by_post_and_peer(
    db: Session,
    *,
    post_uuid: str,
    peer_id: str
):
    stmt = (
        select(chat_rooms)
        .where(
            and_(
                chat_rooms.c.post_uuid == post_uuid,
                chat_rooms.c.peer_id == peer_id,
            )
        )
        .limit(1)
    )

    row = db.execute(stmt).fetchone()
    return row

