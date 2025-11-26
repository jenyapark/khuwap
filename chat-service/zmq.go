package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/pebbe/zmq4"
)

var (
	zmqPush *zmq4.Socket
	zmqPull *zmq4.Socket
)

func initZMQ() {
	var err error

	zmqPush, err = zmq4.NewSocket(zmq4.PUSH)
	if err != nil {
		log.Fatal(err)
	}
	if err := zmqPush.Bind("tcp://*:5555"); err != nil {
		log.Fatal(err)
	}
	fmt.Println("ZeroMQ PUSH bound on 5555")

	zmqPull, err = zmq4.NewSocket(zmq4.PULL)
	if err != nil {
		log.Fatal(err)
	}
	if err := zmqPull.Bind("tcp://*:5556"); err != nil {
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
