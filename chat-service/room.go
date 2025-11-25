package main

import (
	"fmt"

	"github.com/gorilla/websocket"
)

// convID -> userID -> conn
var rooms = map[string]map[string]*websocket.Conn{}

// 방 생성
func ensureRoom(convID string) {
	if rooms[convID] == nil {
		rooms[convID] = map[string]*websocket.Conn{}
		fmt.Println("Room created:", convID)
	}
}

// 방 입장
func joinRoom(convID string, userID string, conn *websocket.Conn) {
	ensureRoom(convID)
	rooms[convID][userID] = conn
	fmt.Printf("User %s joined room %s\n", userID, convID)
}

// 방 퇴장
func leaveRoom(convID string, userID string) {
	if rooms[convID] == nil {
		return
	}
	delete(rooms[convID], userID)
	fmt.Printf("User %s left room %s\n", userID, convID)
}

// 방 가져오기
func getRoom(convID string) map[string]*websocket.Conn {
	return rooms[convID]
}

// 메시지 브로드캐스트
func broadcastToRoom(convID string, msg []byte) {
	room := rooms[convID]
	if room == nil {
		fmt.Println("Room not found:", convID)
		return
	}

	for uid, conn := range room {
		if err := conn.WriteMessage(websocket.TextMessage, msg); err != nil {
			fmt.Println("Send error to", uid, "in room:", convID)
		}
	}
}
