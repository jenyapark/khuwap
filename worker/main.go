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
	// 현재 시간을 시드로 사용하여 랜덤 값 생성
	rand.New(rand.NewSource(time.Now().UnixNano()))
	// "Worker-" + 시간(밀리초) + 랜덤 숫자(0~999) 조합으로 ID 생성
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
			} else {
				log.Printf("[%s] Message processed and saved: %s", workerID, chatMsg.PostUUID)
			}
		}

		// zmq PUSH  Chat Service로 전송 (Worker -> Chat Service)
		push.Send(filtered_msg_json, 0)
	}
}
