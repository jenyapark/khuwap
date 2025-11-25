from sqlalchemy import (
    Table, Column, String, Boolean, DateTime, ForeignKey, Text, func
)
from common.db import metadata
import uuid


chat_rooms = Table(
    "chat_rooms",
    metadata,
    Column("room_id", String, primary_key=True, default=lambda: str(uuid.uuid4())),
    Column("post_uuid", String, ForeignKey("exchange.post_uuid", ondelete="CASCADE"), nullable=False),
    Column("peer_id", String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
    Column("author_id", String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
    Column("last_message", String, server_default=""),
    Column("is_confirmed", Boolean, server_default="false"),
    Column("created_at", DateTime, server_default=func.now()),
    Column("updated_at", DateTime, server_default=func.now(), server_onupdate=func.now()),
)


chat_messages = Table(
    "chat_messages",
    metadata,
    Column("message_id", String, primary_key=True, default=lambda: str(uuid.uuid4())),
    Column("room_id", String, ForeignKey("chat_rooms.room_id", ondelete="CASCADE")),
    Column("sender_id", String, ForeignKey("users.user_id", ondelete="CASCADE")),
    Column("content", Text, nullable=False),
    Column("timestamp", DateTime, server_default=func.now(), nullable=False),
)
