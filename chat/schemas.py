from pydantic import BaseModel

class MessageCreate(BaseModel):
    room_id: str
    sender_id: str
    content: str
