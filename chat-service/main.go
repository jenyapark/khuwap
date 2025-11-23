package main

import (
	"fmt"
	"net/http"

	"github.com/pebbe/zmq4"
)

// zmq 소켓
var zmqPush *zmq4.Socket
var zmqPull *zmq4.Socket

func main() {
	// zmq 초기화
	initZMQ()

	go startWorker()

	// WebSocket 엔드포인트 등록
	http.HandleFunc("/ws", wsHandler)

	fmt.Println("server started on :8080")
	http.ListenAndServe(":8080", nil)
}

// zmq 초기화
func initZMQ() {

	// 서버 -> 워커
	var err error
	zmqPush, err = zmq4.NewSocket(zmq4.PUSH)
	if err != nil {
		panic(err)
	}
	if err := zmqPush.Bind("tcp://*:5555"); err != nil {
		panic(err)
	}
	fmt.Println("ZeroMQ PUSH bound on 5555")

	//워커 -> 서버
	zmqPull, err = zmq4.NewSocket(zmq4.PULL)
	if err != nil {
		panic(err)
	}
	if err := zmqPull.Bind("tcp://*:5556"); err != nil {
		panic(err)
	}
	fmt.Println("ZeroMQ PULL bound on 5556")

	// 워커 -> 서버 메시지 수신
	go handleWorkerMessages()
}
