package main

import (
	"encoding/json"
	"fmt"
)

func handleWorkerMessages() {
	for {
		msg, _ := zmqPull.Recv(0)
		fmt.Println("Server received from worker:", msg)

		var data struct {
			SenderID string `json:"sender_id"`
			PostUUID string `json:"post_uuid"`
			PeerID   string `json:"peer_id"`
			Content  string `json:"content"`
		}

		if err := json.Unmarshal([]byte(msg), &data); err != nil {
			fmt.Println("JSON parsing error:", err)
			continue
		}

		convID := fmt.Sprintf("%s:%d", data.PostUUID, data.PeerID)
		room := rooms[convID]

		if room == nil {
			fmt.Println("Room not found:", convID)
			continue
		}

		// 이 convID에 있는 유저들에게만 전송
		for uid, conn := range room {
			if err := conn.WriteMessage(1, []byte(msg)); err != nil {
				fmt.Println("send error to user:", uid)
			}
		}
	}
}
