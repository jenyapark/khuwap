from sqlalchemy import Table, Column, String, Text, DateTime, ForeignKey, Boolean
from datetime import datetime
import uuid
from common.db import metadata

# 💬 1️⃣ ChatRoom 테이블
chat_rooms = Table(
    "chat_rooms",
    metadata,
    Column("room_id", String, primary_key=True, default=lambda: str(uuid.uuid4())),
    Column("request_uuid", String, ForeignKey("exchange_requests.request_uuid", ondelete="CASCADE")),
    Column("requester_id", String, ForeignKey("users.user_id", ondelete="CASCADE")),
    Column("receiver_id", String, ForeignKey("users.user_id", ondelete="CASCADE")),
    Column("is_confirmed", Boolean, default=False),  # 교환 수락 여부
    Column("created_at", DateTime, default=datetime.utcnow),
)

# 💬 2️⃣ ChatMessage 테이블
chat_messages = Table(
    "chat_messages",
    metadata,
    Column("message_id", String, primary_key=True, default=lambda: str(uuid.uuid4())),
    Column("room_id", String, ForeignKey("chat_rooms.room_id", ondelete="CASCADE")),
    Column("sender_id", String, ForeignKey("users.user_id", ondelete="CASCADE")),
    Column("content", Text, nullable=False),
    Column("timestamp", DateTime, default=datetime.utcnow),
)
