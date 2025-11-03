from pydantic import BaseModel, EmailStr
from datetime import datetime

class User(BaseModel):
    user_id: str
    username: str
    email: EmailStr
    password: str 
    firebase_uid: str | None = None

class UserCreate(User):
    password: str 

class UserResponse(User):
    created_at: datetime

    class Config:
        orm_mode = True
