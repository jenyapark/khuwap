package main

import (
	"bytes"
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

	fmt.Println("Worker started...")

	for {
		msg, err := pull.Recv(0)
		if err != nil {
			fmt.Println("worker recv error:", err)
			continue
		}

		cmd := exec.Command("./filter/target/debug/filter", msg)

		// 메시지를 표준 입력으로 전달
		cmd.Stdin = strings.NewReader(msg)

		// 표준 출력 결과를 받음
		out, err := cmd.Output()
		if err != nil {
			log.Println("Filter command error:", err)
			continue
		}
		trimmed_out := bytes.TrimSpace(out)
		push.Send(string(trimmed_out), 0)
	}
}
