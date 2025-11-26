package main

type PostInfo struct {
	PostID    int    `json:"post_id"`
	PostUUID  string `json:"post_uuid"`
	AuthorID  string `json:"author_id"`
	Current   string `json:"current_course"`
	Desired   string `json:"desired_course"`
	Status    string `json:"status"`
	Note      string `json:"note"`
	CreatedAt string `json:"created_at"`
}

type ChatMessage struct {
	SenderID string `json:"sender_id"`
	PostUUID string `json:"post_uuid"`
	RoomID   string `json:"room_id"`
	PeerID   string `json:"peer_id"`
	Content  string `json:"content"`
}

type RoomInfo struct {
	RoomID   string `json:"room_id"`
	PostUUID string `json:"post_uuid"`
	PeerID   string `json:"peer_id"`
	AuthorID string `json:"author_id"`
}

type RoomsResponse struct {
	Success bool       `json:"success"`
	Data    []RoomInfo `json:"data"`
}
