from sqlalchemy import Table, Column, String, DateTime, ForeignKey, UniqueConstraint
from datetime import datetime, timezone
from common.db import metadata

schedules = Table(
    "schedules",
    metadata,
    Column("user_id", String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
    Column("course_code", String, ForeignKey("courses.course_code", ondelete="CASCADE"), nullable=False),
    Column("enrolled_at", DateTime, default=datetime.now(timezone.utc), nullable = False),

    UniqueConstraint("user_id", "course_code", name="unique_user_course")
)

