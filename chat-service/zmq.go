package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/pebbe/zmq4"
)

var (
	zmqPush *zmq4.Socket
	zmqPull *zmq4.Socket
)

var (
	ZMQPushBind    = getEnv("ZMQ_PUSH_BIND", "tcp://*:5555") // 웹소켓 -> worker 방향
	ZMQPullBind    = getEnv("ZMQ_PULL_BIND", "tcp://*:5556") // worker -> 웹소켓 방향
	wsPort         = getEnv("WS_PORT", "8080")
	coreServiceURL = getEnv("CORE_SERVICE_URL", "http://localhost:8000")
)

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func initZMQ() {
	var err error

	zmqPush, err = zmq4.NewSocket(zmq4.PUSH)
	if err != nil {
		log.Fatal(err)
	}
	if err := zmqPush.Bind(ZMQPushBind); err != nil {
		log.Fatal(err)
	}
	fmt.Println("ZeroMQ PUSH bound on 5555")

	zmqPull, err = zmq4.NewSocket(zmq4.PULL)
	if err != nil {
		log.Fatal(err)
	}
	if err := zmqPull.Bind(ZMQPullBind); err != nil {
		log.Fatal(err)
	}
	fmt.Println("ZeroMQ PULL bound on 5556")
}

func startZMQConsumer() {
	fmt.Println("ZMQ consumer started...")

	for {
		msg, err := zmqPull.Recv(0)
		if err != nil {
			log.Println("ZMQ recv error:", err)
			continue
		}
		fmt.Println("ZMQ consumer received:", msg)

		var data ChatMessage
		if err := json.Unmarshal([]byte(msg), &data); err != nil {
			log.Println("ZMQ JSON decode error:", err)
			continue
		}

		if data.SenderID == "" || data.RoomID == "" {
			log.Println("Invalid ZMQ message: missing SenderID or RoomID, ignore")
			continue
		}

		fmt.Println("broadcast to room:", data.RoomID)

		broadcastToPeers(data.RoomID, msg)
	}
}
