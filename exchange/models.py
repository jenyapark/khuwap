from sqlalchemy import Table, Column, Integer, String, DateTime, ForeignKey
from datetime import datetime
from common.db import metadata
import uuid

exchange = Table(
    "exchange",
    metadata,
    Column("post_id", Integer, primary_key=True, autoincrement=True),  
    Column("exchange_uuid", String, unique=True, default=lambda: str(uuid.uuid4())),
    Column("author_id", String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
    Column("current_course", String, ForeignKey("courses.course_code", ondelete="CASCADE"), nullable=False),
    Column("desired_course", String, ForeignKey("courses.course_code", ondelete="CASCADE"), nullable=False),
    Column("status", String, default="open"),  
    Column("note", String, nullable=True),
    Column("created_at", DateTime, default=datetime.now),
)

exchange_requests = Table(
    "exchange_requests",
    metadata,
    Column("request_id", Integer, primary_key=True, autoincrement=True),
    Column(
        "exchange_post_id",
        Integer,
        ForeignKey("exchange.post_id", ondelete="CASCADE"),
        nullable=False,
    ),
    Column(
        "exchange_post_uuid",
        String,
        ForeignKey("exchange.exchange_uuid", ondelete="CASCADE"),
        nullable=False,
    ),
    Column(
        "requester_id",
        String,
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
    ),
    Column("status", String, default="pending"),
    Column("created_at", DateTime, default=datetime.now),
)