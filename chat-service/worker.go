package main

import (
	"fmt"

	"github.com/pebbe/zmq4"
)

func startWorker() {
	pull, _ := zmq4.NewSocket(zmq4.PULL)
	pull.Connect("tcp://localhost:5555")

	push, _ := zmq4.NewSocket(zmq4.PUSH)
	push.Connect("tcp://localhost:5556")

	fmt.Println("Worker started... waiting for messages")

	for {
		msg, err := pull.Recv(0)
		if err != nil {
			fmt.Println("worker recv error:", err)
			continue
		}

		// ai

		push.Send(msg, 0)
	}
}
