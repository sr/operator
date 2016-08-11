package bread

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"golang.org/x/net/context"
	"golang.org/x/oauth2/clientcredentials"
)

var oauthScopes = []string{"send_message", "send_notification"}

type hipchatClient struct {
	client *http.Client
	host   string
}

type hipchatTransport struct {
	token string
}

func newHipchatClient(
	host string,
	token string,
	oauthID string,
	oauthSecret string,
) *hipchatClient {
	var client *http.Client
	if token != "" {
		client = &http.Client{
			Transport: hipchatTransport{
				token: token,
			},
		}
	} else {
		// TODO(sr) Fetch this from datastore somehow
		config := &clientcredentials.Config{
			ClientID:     oauthID,
			ClientSecret: oauthSecret,
			TokenURL:     fmt.Sprintf("%s/v2/oauth/token", host),
			Scopes:       oauthScopes,
		}
		client = config.Client(context.Background())
	}
	return &hipchatClient{client, host}
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
			notif.RoomID,
		),
		bytes.NewReader(data),
	)
	if err != nil {
		return err
	}
	resp, err := c.doRequest(req)
	if err != nil {
		return fmt.Errorf("hipchat request failed: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != 204 {
		return fmt.Errorf("hipchat request failed with status %d", resp.StatusCode)
	}
	return err
}

func (c *hipchatClient) doRequest(req *http.Request) (*http.Response, error) {
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/json")
	return c.client.Do(req)
}

func (t hipchatTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.Header.Set("Authorization", "Bearer "+t.token)
	return http.DefaultTransport.RoundTrip(req)
}
