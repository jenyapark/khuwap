from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

class ChatRoomBase(BaseModel):
    room_id: str
    post_uuid: str
    peer_id: str
    author_id: str
    last_message: str
    updated_at: datetime


class ChatRoomListResponse(BaseModel):
    success: bool = True
    data: List[ChatRoomBase]

class ChatMessageBase(BaseModel):
    message_id: str
    room_id: str
    sender_id: str
    content: str
    created_at: datetime


class ChatMessageListResponse(BaseModel):
    success: bool = True
    data: List[ChatMessageBase]

class ChatRoomCreateResponse(BaseModel):
    success: bool = True
    room_id: str
    post_uuid: str
    peer_id: str
    author_id: str

class SendMessageRequest(BaseModel):
    room_id: str
    sender_id: str
    content: str

class SendMessageBody(BaseModel):
    room_id: str
    sender_id: str
    content: str