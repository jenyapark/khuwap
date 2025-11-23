package main

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

func wsHandler(w http.ResponseWriter, r *http.Request) {

	// user_id
	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		http.Error(w, "missing user_id", http.StatusBadRequest)
		return
	}

	// post_uuid
	postUUID := r.URL.Query().Get("post_uuid")
	if postUUID == "" {
		http.Error(w, "missing post_uuid", http.StatusBadRequest)
		return
	}

	// peer_id
	peerID := r.URL.Query().Get("peer_id")
	if peerID == "" {
		http.Error(w, "missing peer_id", http.StatusBadRequest)
		return
	}

	// 교환글 상태 & 작성자 조회
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

	// 접속 권한: userID는 반드시 authorID 또는 peerID 둘 중 하나여야 함
	if userID != authorID && userID != peerID {
		http.Error(w, "forbidden: you are not a participant of this conversation", http.StatusForbidden)
		return
	}

	// convID 생성
	convID := fmt.Sprintf("%s:%d", postUUID, peerID)

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

		// 메시지 구조 검사
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

		// URL과 JSON이 일치하는지 검사
		if data.PostUUID != postUUID || data.PeerID != peerID || data.SenderID != userID {
			fmt.Println("Payload mismatch → ignore")
			continue
		}

		// 메시지 워커에게 전달 & (ai)
		zmqPush.Send(string(msg), 0)
	}
}
