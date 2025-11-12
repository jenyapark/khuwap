from sqlalchemy import Table, Column, String, Integer, Time
from common.db import metadata

courses = Table(
    "courses",
    metadata,
    Column("course_code", String, primary_key=True),
    Column("course_name", String, nullable=False),
    Column("professor", String, nullable=False),
    Column("day_of_week", String, nullable=False),
    Column("start_time", Time, nullable=False),
    Column("end_time", Time, nullable=False),
    Column("room", String, nullable=False),
    Column("credit", Integer, nullable=False),
)