package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"os/exec"
	"strings"
	"time"

	"github.com/pebbe/zmq4"
)

func generateWorkerID() string {
	rand.New(rand.NewSource(time.Now().UnixNano()))
	return fmt.Sprintf("Worker-%d-%03d", time.Now().UnixNano()/int64(time.Millisecond), rand.Intn(1000))
}

func main() {
	workerID := generateWorkerID()
	log.Printf("[%s] Worker started and DB persistence enabled...", workerID)

	pull, _ := zmq4.NewSocket(zmq4.PULL)
	pull.Connect("tcp://localhost:5555")

	push, _ := zmq4.NewSocket(zmq4.PUSH)
	push.Connect("tcp://localhost:5556")

	for {

		msg, err := pull.Recv(0)
		if err != nil {
			fmt.Println("worker recv error:", err)
			continue
		}

		// 필터링
		cmd := exec.Command("./filter/target/debug/filter", msg)
		cmd.Stdin = strings.NewReader(msg)
		out, err := cmd.CombinedOutput()
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
				log.Println("Error saving message:", err)
			}
		}

		// zmq PUSH
		push.Send(filtered_msg_json, 0)
	}
}
