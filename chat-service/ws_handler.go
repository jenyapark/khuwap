package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

func wsHandler(w http.ResponseWriter, r *http.Request) {
	userID := strings.TrimSuffix(r.URL.Query().Get("user_id"), "#")
	postUUID := strings.TrimSuffix(r.URL.Query().Get("post_uuid"), "#")
	peerParam := strings.TrimSuffix(r.URL.Query().Get("peer_id"), "#")

	fmt.Println("WS params:", userID, postUUID, peerParam)

	if userID == "" || postUUID == "" || peerParam == "" {
		http.Error(w, "missing parameters", http.StatusBadRequest)
		return
	}

	if userID == peerParam {
		http.Error(w, "user_id and peer_id cannot be the same", http.StatusBadRequest)
		return
	}

	// 글 정보 조회
	postInfo, err := getPostInfo(postUUID)
	if err != nil {
		log.Println("getPostInfo error:", err)
		http.Error(w, "failed to fetch post info", http.StatusInternalServerError)
		return
	}

	if postInfo.Status == "completed" {
		http.Error(w, "This post is already completed", http.StatusForbidden)
		return
	}

	authorID := postInfo.AuthorID

	// 참여자 결정
	var otherID string
	switch {
	case userID == authorID:
		otherID = peerParam
	case peerParam == authorID:
		otherID = userID
	default:
		http.Error(w, "invalid user/post/peer combination", http.StatusForbidden)
		return
	}

	// 방 convID = post + 두 명 정렬
	convID := makeConvID(postUUID, authorID, otherID)

	// 코어 서비스 방 생성/조회
	roomID, err := getRoomFromAPI(postUUID, authorID, otherID)
	if err != nil {
		log.Println("getRoomFromAPI error:", err)
		http.Error(w, "invalid chat room", http.StatusForbidden)
		return
	}

	// WebSocket 업그레이드
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("upgrade error:", err)
		return
	}

	joinRoom(convID, userID, conn)

	// 상대방 ID
	var peerForThisUser string
	if userID == authorID {
		peerForThisUser = otherID
	} else {
		peerForThisUser = authorID
	}

	// 연결 종료 핸들링
	defer func() {
		leaveRoom(convID, userID)
		conn.Close()
	}()

	// 메시지 읽기 루프
	for {
		_, raw, err := conn.ReadMessage()
		if err != nil {
			log.Println("read error:", err)
			return
		}

		var data ChatMessage
		if err := json.Unmarshal(raw, &data); err != nil {
			log.Println("JSON decode error:", err)
			continue
		}

		fmt.Println("RAW MSG:", string(raw))
		fmt.Println("PARSED:", data)
		fmt.Println("EXPECTED sender:", userID)
		fmt.Println("EXPECTED post:", postUUID)
		fmt.Println("EXPECTED peer:", peerForThisUser)

		// 검증
		if data.SenderID != userID ||
			data.PostUUID != postUUID ||
			data.PeerID != peerForThisUser {
			fmt.Println("Payload mismatch → ignore")
			continue
		}

		// 워커로 전달
		if _, err := zmqPush.Send(string(raw), 0); err != nil {
			log.Println("ZMQ send error:", err)
		}

		if err := saveChatMessageToAPI(roomID, data.SenderID, data.Content); err != nil {
			log.Println("saveChatMessageToAPI error:", err)
		}
	}
}
