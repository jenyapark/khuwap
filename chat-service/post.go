package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type PostInfo struct {
	Status   string
	AuthorID string
}

// 전체 정보 조회 (status + author_id)
func getPostInfo(uuid string) (PostInfo, error) {

	// 너 FastAPI 실제 주소 맞춰서 여기에 넣으면 됨
	url := "http://localhost:8000/exchange/" + uuid

	resp, err := http.Get(url)
	if err != nil {
		return PostInfo{}, err
	}
	defer resp.Body.Close()

	var result struct {
		Success bool `json:"success"`
		Data    struct {
			Status   string `json:"status"`
			AuthorID string `json:"author_id"`
		} `json:"data"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return PostInfo{}, err
	}
	if !result.Success {
		return PostInfo{}, fmt.Errorf("Backend returned success=false")
	}

	return PostInfo{
		Status:   result.Data.Status,
		AuthorID: result.Data.AuthorID,
	}, nil
}

// status만 필요할 때
func getPostStatus(uuid string) (string, error) {
	info, err := getPostInfo(uuid)
	if err != nil {
		return "", err
	}
	return info.Status, nil
}
