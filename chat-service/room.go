package main

import (
	"log"
	"sync"

	"github.com/gorilla/websocket"
)

var (
	userConns   = make(map[string]*websocket.Conn)
	userConnsMu sync.RWMutex

	roomParticipants   = make(map[string][]string)
	roomParticipantsMu sync.RWMutex
)

func registerUserRooms(userID string) {
	rooms, err := getMyRooms(userID)
	if err != nil {
		log.Println("Failed to fetch user rooms for broadcast:", err)
		return
	}

	roomParticipantsMu.Lock()
	defer roomParticipantsMu.Unlock()

	for _, room := range rooms {
		roomParticipants[room.RoomID] = []string{room.AuthorID, room.PeerID}
	}
}

// 특정 게시글(PostUUID)의 참여자들에게 메시지 브로드캐스트
func broadcastToPeers(roomID string, rawMsg string) {
	roomParticipantsMu.RLock()
	participants, ok := roomParticipants[roomID]
	roomParticipantsMu.RUnlock()

	if !ok {
		log.Println("Broadcast failed: RoomID not found in active map:", roomID)
		return
	}

	userConnsMu.RLock()
	defer userConnsMu.RUnlock()

	connsToSend := make(map[string]*websocket.Conn)

	for _, uid := range participants {
		if c, ok := userConns[uid]; ok {
			connsToSend[uid] = c
		}
	}

	for uid, c := range connsToSend {
		if err := c.WriteMessage(1, []byte(rawMsg)); err != nil {
			log.Println("broadcast error to", uid, ":", err)
			userConnsMu.Lock()
			delete(userConns, uid) // 오류 발생 시 연결 제거
			userConnsMu.Unlock()
		}
	}
}
