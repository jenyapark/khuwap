package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"os/exec"
	"strings"

	"github.com/pebbe/zmq4"
)

func main() {
	pull, _ := zmq4.NewSocket(zmq4.PULL)
	pull.Connect("tcp://localhost:5555")

	push, _ := zmq4.NewSocket(zmq4.PUSH)
	push.Connect("tcp://localhost:5556")

	fmt.Println("Worker started and DB persistence enabled...")

	for {

		//zmq 메시지 수신 (클라이언트 -> Chat Service -> Worker)
		msg, err := pull.Recv(0)
		if err != nil {
			fmt.Println("worker recv error:", err)
			continue
		}

		// 필터링
		cmd := exec.Command("./filter/target/debug/filter", msg)
		cmd.Stdin = strings.NewReader(msg)
		out, err := cmd.Output()
		if err != nil {
			log.Println("Filter command error:", err)
			continue
		}

		trimmed_out := bytes.TrimSpace(out)
		filtered_msg_json := string(trimmed_out)

		var chatMsg ChatMessage
		if err := json.Unmarshal([]byte(filtered_msg_json), &chatMsg); err != nil {
			log.Println("Error unmarshalling filtered message for API call:", err)
		}

		if chatMsg.RoomID != "" {
			if err := SaveMessageViaAPI(&chatMsg); err != nil {
				log.Println("Error saving message via API:", err)
			}
		}

		// zmq PUSH  Chat Service로 전송 (Worker -> Chat Service)
		push.Send(filtered_msg_json, 0)
	}
}
