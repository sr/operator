package bread

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"

	"golang.org/x/net/context"
	"golang.org/x/oauth2/clientcredentials"
)

const descriptorTmpl = `
{
	"name": "Operator",
	"key": "com.pardot.ops.operator.%s",
	"description": "ChatOps",
	"links": {
		"homepage": "https://git.dev.pardot.com/Pardot/bread",
		"self": "%s"
	},
	"capabilities": {
		"installable": {
			"allowGlobal": true,
			"allowRoom": false,
			"callbackUrl": "%s"
		},
		"hipchatApiConsumer": {
			"scopes": [
				"send_message",
				"send_notification"
			]
		}
	}
}
`

var oauthScopes = []string{"send_message", "send_notification"}

type hipchatClient struct {
	client *http.Client
	host   string
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
			Transport: tokenTransport{token},
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

type tokenTransport struct {
	token string
}

func (t tokenTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	req.Header.Set("Authorization", "Bearer "+t.token)
	return http.DefaultTransport.RoundTrip(req)
}

type hipchatAddonHandler struct {
	url        *url.URL
	descriptor string
}

func newHipchatAddonHandler(id string, url *url.URL) *hipchatAddonHandler {
	return &hipchatAddonHandler{
		url,
		fmt.Sprintf(
			descriptorTmpl,
			id,
			url.String(),
			url.String(),
		),
	}
}

func (h *hipchatAddonHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method == "GET" && req.URL.Path == h.url.Path {
		req.Header.Set("Content-Type", "application/json")
		w.Write([]byte(h.descriptor))
		return
	}
	if req.Method == "POST" && req.URL.Path == h.url.Path {
		type payload struct {
			URL         string `json:"capabilitiesUrl"`
			OAuthID     string `json:"oauthId"`
			OAuthSecret string `json:"oauthSecret"`
		}
		var data payload
		decoder := json.NewDecoder(req.Body)
		if err := decoder.Decode(&data); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte(err.Error()))
			return
		}
		// TODO(sr) Save the OAuth secret token somewhere safe.
		fmt.Printf("callback %#v\n", data)
		return
	}
	w.WriteHeader(http.StatusNotFound)
}
