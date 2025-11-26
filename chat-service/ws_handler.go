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
	if userID == "" {
		http.Error(w, "missing user_id parameter", http.StatusBadRequest)
		return
	}
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("upgrade error:", err)
		return
	}

	// 사용자 연결 등록 (userConns 맵에 저장)
	registerUserConn(userID, conn)
	fmt.Println("User registered:", userID)
	registerUserRooms(userID)

	// 연결 종료 핸들링
	defer func() {
		deregisterUserConn(userID) // 연결 해제 시 맵에서 제거
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

		// 유효성 검사
		if data.SenderID != userID || data.PostUUID == "" {
			fmt.Println("Invalid payload: missing PostUUID or mismatched SenderID → ignore")
			continue
		}

		// 워커로 전달 (저장/필터링 작업은 워커에게 위임)
		if _, err := zmqPush.Send(string(raw), 0); err != nil {
			log.Println("ZMQ send error:", err)
		}
	}

}
