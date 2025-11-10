from sqlalchemy import Table, Column, Integer, String, DateTime
from datetime import datetime
from common.db import metadata

users = Table(
    "users",
    metadata,
    Column("user_id", String, primary_key=True),
    Column("firebase_uid", String, unique=True, nullable=True),        
    Column("username", String, nullable=False),                       
    Column("email", String, unique=True, nullable=False),              
    Column("password", String, nullable=False),                         
    Column("created_at", DateTime, default=datetime.utcnow), 
    Column("max_credit", Integer, nullable=False, default = 18)
)

