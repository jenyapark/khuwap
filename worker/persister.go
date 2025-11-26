package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

const coreServiceURL = "http://localhost:8000"

func SaveMessageViaAPI(msg *ChatMessage) error {
	// 메시지 구조체를 JSON 바이트로 변환
	msgBytes, err := json.Marshal(msg)
	if err != nil {
		return fmt.Errorf("marshalling error: %w", err)
	}

	// 메시지 저장
	resp, err := http.Post(
		coreServiceURL+"/chat/send",
		"application/json",
		bytes.NewBuffer(msgBytes),
	)
	if err != nil {
		return fmt.Errorf("API request error: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body := new(bytes.Buffer)
		body.ReadFrom(resp.Body)
		return fmt.Errorf("API returned non-OK status: %d, response body: %s", resp.StatusCode, body.String())
	}
	return nil
}
