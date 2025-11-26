package main

type ChatMessage struct {
	SenderID string `json:"sender_id"`
	PostUUID string `json:"post_uuid"`
	PeerID   string `json:"peer_id"`
	RoomID   string `json:"room_id"`
	Content  string `json:"content"`
}
