// Package breadhipchat implements parts of the Hipchat HTTP API that are
// useful for the BREAD team.
package breadhipchat

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

var DefaultScopes = []string{"send_message", "send_notification", "view_group"}

type Client struct {
	hostname   string
	httpclient *http.Client
}

type ClientConfig struct {
	Hostname    string
	Token       string
	Credentials *ClientCredentials
	Scopes      []string
}

type ClientCredentials struct {
	ID     string
	Secret string
}

type RoomNotification struct {
	*MessageOptions
	Message       string `json:"message"`
	MessageFormat string `json:"message_format"`
	RoomID        int64  `json:"-"`
}

type MessageOptions struct {
	Color string `json:"color"`
	From  string `json:"from"`
}

type User struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Email       string `json:"email"`
	Deleted     bool   `json:"is_deleted"`
	MentionName string `json:"mention_name"`
}

func NewClient(ctx context.Context, config *ClientConfig) (*Client, error) {
	if config.Hostname == "" {
		config.Hostname = defaultHostname
	}
	if config.Scopes == nil {
		config.Scopes = DefaultScopes
	}
	if config.Token != "" {
		return &Client{
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
		return &Client{
			config.Hostname,
			cfg.Client(ctx),
		}, nil
	} else {
		return nil, errors.New("one of config.Token or config.Credentials must be set")
	}
}

func (c *Client) GetUser(ctx context.Context, id int) (*User, error) {
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

func (c *Client) SendRoomNotification(ctx context.Context, notif *RoomNotification) error {
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

func (c *Client) do(ctx context.Context, req *http.Request, status int) (*http.Response, error) {
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
