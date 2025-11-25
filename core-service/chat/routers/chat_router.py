from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import select, insert, delete, update, and_, or_

from chat.schemas import SendMessageBody
from chat.models import chat_messages, chat_rooms, chat_read_state

from common.db import get_db
from chat.services.chat_room_service import (
    get_my_chat_rooms,
    get_or_create_chat_room,
    update_chat_room_last_message,
    get_room_by_post_and_peer,
)
from chat.services.chat_message_service import (
    save_message,
    get_messages_by_room,
)

from chat.services.read_state_service import (
    get_unread_count,
    update_read_state,
)
router = APIRouter(tags=["chat"])


# 내가 참여한 채팅방 목록 조회
@router.get("/rooms")
def get_chat_rooms(user_id: str, db: Session = Depends(get_db)):
    rooms = get_my_chat_rooms(db, user_id)

    data = []

    for r in rooms:
        unread = get_unread_count(
            db,
            room_id=r.room_id,
            user_id=user_id
        )

        data.append({
            "room_id": r.room_id,
            "post_uuid": r.post_uuid,
            "peer_id": r.peer_id,
            "author_id": r.author_id,
            "last_message": r.last_message,
            "updated_at": r.updated_at.isoformat(),
            "unread_count": unread,       # ← 추가됨
        })

    return {
        "success": True,
        "data": data
    }

# 특정 방의 메시지 리스트 조회
@router.get("/messages")
def get_room_messages(room_id: str, user_id: str, db: Session = Depends(get_db)):
    rows = get_messages_by_room(db, room_id=room_id)
    update_read_state(db, room_id=room_id, user_id=user_id)

    return {
        "success": True,
        "data": [
            {
                "message_id": r.message_id,
                "room_id": r.room_id,
                "sender_id": r.sender_id,
                "content": r.content,
                "timestamp": r.timestamp.isoformat(),
            }
            for r in rows
        ]
    }


# 메시지 저장 (Go WebSocket 서버가 호출할 수 있는 API)
@router.post("/send")
def send_chat_message(payload: SendMessageBody, db: Session = Depends(get_db)):
    
    row = db.execute(
        select(chat_rooms)
        .where(chat_rooms.c.room_id == payload.room_id)
        .limit(1)
    ).fetchone()

    if not row:
        raise HTTPException(status_code=404, detail="room not found")

    # 2) 권한 검증: sender_id ∈ {author_id, peer_id}
    if payload.sender_id not in [row.author_id, row.peer_id]:
        raise HTTPException(status_code=403, detail="not a participant")

    
    save_message(
        db,
        room_id=payload.room_id,
        sender_id=payload.sender_id,
        content=payload.content,
    )

    update_chat_room_last_message(
        db,
        room_id=payload.room_id,
        last_message=payload.content,
    )

    return {"success": True}


# 4) 방 자동 생성용 API 
@router.post("/room/create")
def create_room(
    post_uuid: str,
    author_id: str,
    peer_id: str,
    db: Session = Depends(get_db)
):
    row = get_or_create_chat_room(
        db,
        post_uuid=post_uuid,
        author_id=author_id,
        peer_id=peer_id,
    )

    return {
        "success": True,
        "room_id": row.room_id,
        "post_uuid": row.post_uuid,
        "peer_id": row.peer_id,
        "author_id": row.author_id,
    }
