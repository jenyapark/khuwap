from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import select, insert, delete, update, and_, or_
from common.db import engine
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

    try:
    
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
        db.commit()

        return {"success": True}
    except Exception as e:
        print("--- FATAL MESSAGE SAVE ERROR ---")
        traceback.print_exc()
        print(f"Error details: {e}")
        print("--------------------------------")
        
        # 클라이언트(Worker)에게 500 오류 반환
        raise HTTPException(status_code=500, detail="Internal Server Error")



# 4) 방 자동 생성용 API 
@router.post("/room/create")
def create_room(
    post_uuid: str,
    author_id: str,
    peer_id: str,
    db: Session = Depends(get_db)
):

    with engine.connect() as conn:
        # 먼저 기존 방 탐색
        existing = conn.execute(
            select(chat_rooms)
            .where(chat_rooms.c.post_uuid == post_uuid)
            .where(
            or_(
                # Case 1: 요청받은 A(author), B(peer) 순서대로 방이 존재할 때
                and_(chat_rooms.c.author_id == author_id, chat_rooms.c.peer_id == peer_id),
                
                # Case 2: B(author), A(peer) 순서가 뒤바뀌어 방이 이미 존재할 때
                and_(chat_rooms.c.author_id == peer_id, chat_rooms.c.peer_id == author_id), 
            ))  ).mappings().first()

        if existing:
            return {
                "success": True,
                "room_id": existing["room_id"],
                "created": False
            }
        
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

@router.delete("/chat/room/{room_id}")
def delete_chat_room(room_id: str):
    with engine.connect() as conn:
        result = conn.execute(
            delete(chat_rooms).where(chat_rooms.c.room_id == room_id)
        )

        conn.commit()

        if result.rowcount == 0:
            return {"message": "삭제할 채팅방이 없음.", "room_id": room_id}

        return {"message": "채팅방 삭제 완료", "room_id": room_id}
