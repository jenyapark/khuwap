from pydantic import BaseModel, EmailStr
from datetime import datetime

class User(BaseModel):
    user_id: str
    username: str
    email: EmailStr
    password: str | None = None
    firebase_uid: str | None = None

class UserCreate(User):
    password: str | None = None

class UserResponse(User):
    created_at: datetime

    class Config:
        orm_mode = True
