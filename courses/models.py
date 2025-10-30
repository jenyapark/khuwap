from sqlalchemy import Table, Column, String, Integer, Time
from common.db import metadata

courses = Table(
    "courses",
    metadata,
    Column("course_code", String, primary_key=True),
    Column("course_name", String, nullable=False),
    Column("professor", String, nullable=True),
    Column("day_of_week", String, nullable=True),
    Column("start_time", Time, nullable=True),
    Column("end_time", Time, nullable=True),
    Column("room", String, nullable=True),
    Column("credit", Integer, nullable=True),
)

