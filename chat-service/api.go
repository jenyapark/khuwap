package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

type postInfoResponse struct {
	Success bool     `json:"success"`
	Message string   `json:"message"`
	Data    PostInfo `json:"data"`
}

func getPostInfo(postUUID string) (*PostInfo, error) {
	url := fmt.Sprintf("http://localhost:8000/exchange/%s", postUUID)

	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var out postInfoResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, err
	}

	if !out.Success {
		return nil, fmt.Errorf("backend returned success=false")
	}

	return &out.Data, nil
}

func getRoomFromAPI(postUUID, authorID, peerID string) (string, error) {
	url := fmt.Sprintf(
		"http://localhost:8000/chat/room/create?post_uuid=%s&author_id=%s&peer_id=%s",
		postUUID,
		authorID,
		peerID,
	)

	resp, err := http.Post(url, "application/json", nil)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var out struct {
		Success bool   `json:"success"`
		RoomID  string `json:"room_id"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return "", err
	}

	if !out.Success {
		return "", fmt.Errorf("backend returned success=false")
	}

	return out.RoomID, nil
}

func saveChatMessageToAPI(roomID, senderID, content string) error {
	bodyMap := map[string]string{
		"room_id":   roomID,
		"sender_id": senderID,
		"content":   content,
	}
	body, _ := json.Marshal(bodyMap)

	resp, err := http.Post(
		"http://localhost:8000/chat/send",
		"application/json",
		bytes.NewBuffer(body),
	)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("FastAPI returned %s", resp.Status)
	}

	return nil
}

func getMyRooms(userID string) ([]RoomInfo, error) {
	url := fmt.Sprintf("http://localhost:8000/chat/rooms?user_id=%s", userID)

	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to make request to core API: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("core API returned status: %d", resp.StatusCode)
	}

	var out RoomsResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, fmt.Errorf("failed to decode core API response JSON: %w", err)
	}

	if !out.Success {
		return nil, fmt.Errorf("core API returned success: false")
	}

	return out.Data, nil
}
