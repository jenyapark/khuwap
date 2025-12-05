package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func getMyRooms(userID string) ([]RoomInfo, error) {
	url := fmt.Sprintf("%s/chat/rooms?user_id=%s", coreServiceURL, userID)

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
