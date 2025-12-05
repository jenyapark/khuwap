from pydantic import BaseModel, EmailStr
from datetime import datetime

class User(BaseModel):
    user_id: str
    username: str
    email: EmailStr
    password: str 
    max_credit: int

class UserCreate(User):
    pass

class UserResponse(User):
    firebase_uid: str | None = None
    created_at: datetime

    class Config:
        orm_mode = True

class UserLogin(BaseModel):
    email: str
    password: str