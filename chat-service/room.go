package main

import (
	"fmt"
	"log"
	"sort"
	"sync"

	"github.com/gorilla/websocket"
)

var (
	rooms   = make(map[string]*Room)
	roomsMu sync.RWMutex
)

type Room struct {
	ID    string
	Conns map[string]*websocket.Conn // userID → conn
}

// 두 참여자를 정렬해서 convID 생성
func makeConvID(postUUID, userA, userB string) string {
	ids := []string{userA, userB}
	sort.Strings(ids)
	return fmt.Sprintf("%s:%s:%s", postUUID, ids[0], ids[1])
}

// 방 입장
func joinRoom(convID, userID string, conn *websocket.Conn) {
	roomsMu.Lock()
	defer roomsMu.Unlock()

	room, ok := rooms[convID]
	if !ok {
		room = &Room{
			ID:    convID,
			Conns: make(map[string]*websocket.Conn),
		}
		rooms[convID] = room
		fmt.Println("Room created:", convID)
	}

	// 기존 연결 있으면 제거
	if old, exists := room.Conns[userID]; exists && old != conn {
		fmt.Println("기존 연결 감지 → 강제 종료:", convID, "user:", userID)
		old.Close()
	}

	room.Conns[userID] = conn
	fmt.Println("User joined:", userID, "room:", convID)
}

// 방 나가기
func leaveRoom(convID, userID string) {
	roomsMu.Lock()
	defer roomsMu.Unlock()

	room, ok := rooms[convID]
	if !ok {
		return
	}

	delete(room.Conns, userID)
	fmt.Println("User left:", userID, "room:", convID)

	if len(room.Conns) == 0 {
		delete(rooms, convID)
		fmt.Println("Room removed:", convID)
	}
}

// 방 전체에 메시지 브로드캐스트
func broadcastToRoom(convID string, rawMsg string) {
	roomsMu.RLock()
	room, ok := rooms[convID]
	if !ok {
		roomsMu.RUnlock()
		return
	}

	// 복사하여 잠금 짧게 유지
	conns := make(map[string]*websocket.Conn)
	for uid, c := range room.Conns {
		conns[uid] = c
	}
	roomsMu.RUnlock()

	for uid, c := range conns {
		if err := c.WriteMessage(1, []byte(rawMsg)); err != nil {
			log.Println("broadcast error to", uid, ":", err)
			roomsMu.Lock()
			delete(room.Conns, uid)
			roomsMu.Unlock()
		}
	}
}
