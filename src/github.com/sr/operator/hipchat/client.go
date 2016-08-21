package operatorhipchat

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/sr/operator"

	"golang.org/x/net/context"
	"golang.org/x/net/context/ctxhttp"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"
)

const defaultHostname = "api.hipchat.com"

type client struct {
	hostname string
	cli      *http.Client
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

func (c *client) SendRoomNotification(ctx context.Context, notif *operator.ChatRoomNotification) error {
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
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/json")
	resp, err := ctxhttp.Do(ctx, c.cli, req)
	if err != nil {
		return fmt.Errorf("hipchat request failed: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != 204 {
		return fmt.Errorf("hipchat request failed with status %d", resp.StatusCode)
	}
	return err
}
