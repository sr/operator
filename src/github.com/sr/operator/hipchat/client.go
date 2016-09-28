package operatorhipchat

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"

	"golang.org/x/net/context"
	"golang.org/x/net/context/ctxhttp"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"
)

// TODO(sr) Store the hostname alongs with the OAuth ID and OAuth Secret in the DB
const defaultHostname = "api.hipchat.com"

type client struct {
	hostname   string
	httpclient *http.Client
}

func newClient(ctx context.Context, config *ClientConfig) (*client, error) {
	if config.Hostname == "" {
		config.Hostname = defaultHostname
	}
	if config.Scopes == nil {
		config.Scopes = DefaultScopes
	}
	if config.Token != "" {
		return &client{
			config.Hostname,
			oauth2.NewClient(
				ctx,
				oauth2.StaticTokenSource(
					&oauth2.Token{
						AccessToken: config.Token,
						TokenType:   "Bearer",
					},
				),
			),
		}, nil
	} else if config.Credentials != nil {
		cfg := &clientcredentials.Config{
			ClientID:     config.Credentials.ID,
			ClientSecret: config.Credentials.Secret,
			TokenURL:     fmt.Sprintf("%s/v2/oauth/token", config.Hostname),
			Scopes:       config.Scopes,
		}
		return &client{
			config.Hostname,
			cfg.Client(ctx),
		}, nil
	} else {
		return nil, errors.New("one of config.Token or config.Credentials must be set")
	}
}

func (c *client) GetUser(ctx context.Context, id int) (*User, error) {
	req, err := http.NewRequest(
		"GET",
		fmt.Sprintf(
			"%s/v2/user/%d",
			c.hostname,
			id,
		),
		nil,
	)
	if err != nil {
		return nil, err
	}
	resp, err := c.do(ctx, req, 200)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	var user User
	decoder := json.NewDecoder(resp.Body)
	if err := decoder.Decode(&user); err != nil {
		return nil, err
	}
	return &user, nil
}

func (c *client) SendRoomNotification(ctx context.Context, notif *RoomNotification) error {
	data, err := json.Marshal(notif)
	if err != nil {
		return err
	}
	req, err := http.NewRequest(
		"POST",
		fmt.Sprintf(
			"%s/v2/room/%d/notification",
			c.hostname,
			notif.RoomID,
		),
		bytes.NewReader(data),
	)
	if err != nil {
		return err
	}
	_, err = c.do(ctx, req, 204)
	return err
}

func (c *client) do(ctx context.Context, req *http.Request, status int) (*http.Response, error) {
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/json")
	resp, err := ctxhttp.Do(ctx, c.httpclient, req)
	if err != nil {
		return nil, fmt.Errorf("hipchat request failed: %v", err)
	}
	if resp.StatusCode != status {
		defer func() { _ = resp.Body.Close() }()
		if body, err := ioutil.ReadAll(resp.Body); err == nil {
			return nil, fmt.Errorf("hipchat request failed with status %d (expected %d) and body: %s", resp.StatusCode, status, body)
		}
		return nil, fmt.Errorf("hipchat request failed with status %d (expected %d)", resp.StatusCode, status)
	}
	return resp, err
}
