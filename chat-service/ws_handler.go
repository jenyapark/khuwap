package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

// FastAPI /chat/room/create 호출해서 room_id 확보
func getRoomFromAPI(postUUID, authorID, peerID string) (string, error) {
	url := fmt.Sprintf(
		"http://localhost:8000/chat/room/create?post_uuid=%s&author_id=%s&peer_id=%s",
		postUUID,
		authorID,
		peerID,
	)

	resp, err := http.Post(url, "application/json", nil)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var out struct {
		Success  bool   `json:"success"`
		RoomID   string `json:"room_id"`
		PostUUID string `json:"post_uuid"`
		PeerID   string `json:"peer_id"`
		AuthorID string `json:"author_id"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return "", err
	}

	if !out.Success {
		return "", fmt.Errorf("backend returned success=false")
	}

	return out.RoomID, nil
}

// FastAPI /chat/send 호출해서 메시지 저장
func saveChatMessageToAPI(roomID, senderID, content string) error {
	payload := map[string]string{
		"room_id":   roomID,
		"sender_id": senderID,
		"content":   content,
	}

	body, _ := json.Marshal(payload)

	resp, err := http.Post(
		"http://localhost:8000/chat/send",
		"application/json",
		bytes.NewBuffer(body),
	)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("FastAPI returned %s", resp.Status)
	}

	return nil
}

func wsHandler(w http.ResponseWriter, r *http.Request) {

	userID := r.URL.Query().Get("user_id")
	postUUID := r.URL.Query().Get("post_uuid")
	peerID := r.URL.Query().Get("peer_id")

	if userID == "" || postUUID == "" || peerID == "" {
		http.Error(w, "missing parameters", http.StatusBadRequest)
		return
	}

	// 글 정보 조회 (status + author_id)
	postInfo, err := getPostInfo(postUUID)
	if err != nil {
		http.Error(w, "failed to fetch post info", http.StatusInternalServerError)
		return
	}

	if postInfo.Status == "completed" {
		http.Error(w, "this post is already completed", http.StatusForbidden)
		return
	}

	authorID := postInfo.AuthorID

	// 사용자 검증
	if userID != authorID && userID != peerID {
		http.Error(w, "forbidden: you are not a participant of this conversation", http.StatusForbidden)
		return
	}
	var roomID string

	roomID, err = getRoomFromAPI(postUUID, authorID, peerID)
	if err != nil {
		http.Error(w, "invalid chat room", http.StatusForbidden)
		return
	}

	// convID 생성
	convID := fmt.Sprintf("%s:%s", postUUID, peerID)

	// 웹소켓 업그레이드
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Println("Upgrade error:", err)
		return
	}

	fmt.Println("User connected:", userID, "convID:", convID)

	// 방 등록
	joinRoom(convID, userID, conn)

	// 메시지 루프
	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			fmt.Println("User disconnected:", userID, "convID:", convID)
			leaveRoom(convID, userID)
			return
		}

		var data struct {
			SenderID string `json:"sender_id"`
			PostUUID string `json:"post_uuid"`
			PeerID   string `json:"peer_id"`
			Content  string `json:"content"`
		}

		if err := json.Unmarshal(msg, &data); err != nil {
			fmt.Println("JSON error:", err)
			continue
		}

		// URL 파라미터와 JSON 검증
		if data.PostUUID != postUUID || data.PeerID != peerID || data.SenderID != userID {
			fmt.Println("Payload mismatch → ignore")
			continue
		}

		// 메시지를 worker로 전달
		zmqPush.Send(string(msg), 0)

		// 메시지 저장 API 호출
		if err := saveChatMessageToAPI(roomID, data.SenderID, data.Content); err != nil {
			fmt.Println("Failed to save message:", err)
		}
	}
}
