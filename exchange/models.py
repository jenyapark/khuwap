from sqlalchemy import Table, Column, String, DateTime, ForeignKey
from datetime import datetime
from common.db import metadata

exchange = Table(
    "exchange",
    metadata,
    Column("post_id", String, primary_key=True),  
    Column("author_id", String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
    Column("current_course", String, ForeignKey("courses.course_code", ondelete="CASCADE"), nullable=False),
    Column("desired_course", String, ForeignKey("courses.course_code", ondelete="CASCADE"), nullable=False),
    Column("status", String, default="OPEN"),  
    Column("created_at", DateTime, default=datetime.utcnow)
)

