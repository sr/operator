package bread

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

type hipchatClient struct {
	client *http.Client
	host   string
}

type hipchatTransport struct {
	token string
}

func newHipchatClient(host string, token string) *hipchatClient {
	return &hipchatClient{
		host: host,
		client: &http.Client{
			Transport: hipchatTransport{
				token: token,
			},
		},
	}
}

func (c *hipchatClient) SendRoomNotification(notif *ChatRoomNotification) error {
	data, err := json.Marshal(notif)
	if err != nil {
		return err
	}
	req, err := http.NewRequest(
		"POST",
		fmt.Sprintf(
			"%s/v2/room/%d/notification",
			c.host,
			notif.RoomId,
		),
		bytes.NewReader(data),
	)
	if err != nil {
		return err
	}
	resp, err := c.client.Do(req)
	if err != nil {
		return fmt.Errorf("hipchat request failed: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != 204 {
		return fmt.Errorf("hipchat request failed with status %d", resp.StatusCode)
	}
	return err
}

func (t hipchatTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.Header.Set("Authorization", "Bearer "+t.token)
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/json")
	return http.DefaultTransport.RoundTrip(req)
}
