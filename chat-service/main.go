package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	// ZMQ 초기화 + 워커 수신 고루틴
	initZMQ()
	go startZMQConsumer()

	// WebSocket 핸들러 등록
	http.HandleFunc("/ws", wsHandler)

	fmt.Println("server started on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
