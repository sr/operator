package bread

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"fmt"
	"html/template"
	"net/http"
	"net/url"

	"github.com/sr/operator"

	"golang.org/x/net/context"
	"golang.org/x/oauth2/clientcredentials"
)

var descriptorTmpl = template.Must(template.New("descriptor.json").Parse(`{
	"name": "Operator {{.AddonID}}",
	"key": "com.pardot.dev.operator.{{.AddonID}}",
	"description": "ChatOps",
	"links": {
		"homepage": "https://git.dev.pardot.com/Pardot/bread",
		"self": "{{.AddonURL}}"
	},
	"capabilities": {
		"installable": {
			"allowGlobal": true,
			"allowRoom": false,
			"callbackUrl": "{{.AddonURL}}"
		},
		"webhook": [
			{
				"url": "{{.WebhookURL}}",
				"pattern": "{{.Pattern}}",
				"event": "room_message",
				"authentication": "jwt",
				"name": "Operator"
			}
		],
		"hipchatApiConsumer": {
			"scopes": [
				"send_message",
				"send_notification"
			]
		}
	}
}`))

var oauthScopes = []string{"send_message", "send_notification"}

type hipchatClient struct {
	client   *http.Client
	hostname string
}

type hipchatAccessTokenStore struct {
	db      *sql.DB
	addonID string
}

func (s *hipchatAccessTokenStore) Get() (*HipchatConfig, error) {
	var (
		oauthID     string
		oauthSecret string
	)
	row := s.db.QueryRow(`
		SELECT oauth_id, oauth_secret
		FROM hipchat_addon_installs WHERE addon_id = ?`,
		s.addonID,
	)
	if err := row.Scan(&oauthID, &oauthSecret); err != nil {
		return nil, err
	}
	return &HipchatConfig{
		OAuthID:     oauthID,
		OAuthSecret: oauthSecret,
	}, nil
}

func (s *hipchatAccessTokenStore) Set(oauthID, oauthSecret string) error {
	_, err := s.db.Exec(`
		INSERT INTO hipchat_addon_installs (
			created_at,
			addon_id,
			oauth_id,
			oauth_secret
		)
		VALUES (NOW(), ?, ?, ?)`,
		s.addonID,
		oauthID,
		oauthSecret,
	)
	return err
}

func newHipchatClient(config *HipchatConfig) *hipchatClient {
	if config.Token != "" {
		return &hipchatClient{
			&http.Client{Transport: tokenTransport{config.Token}},
			config.Hostname,
		}
	}
	cfg := &clientcredentials.Config{
		ClientID:     config.OAuthID,
		ClientSecret: config.OAuthSecret,
		TokenURL:     fmt.Sprintf("%s/v2/oauth/token", config.Hostname),
		Scopes:       oauthScopes,
	}
	// TODO(sr) Proper context
	return &hipchatClient{
		cfg.Client(context.Background()),
		config.Hostname,
	}
}

func (c *hipchatClient) SendRoomNotification(notif *operator.ChatRoomNotification) error {
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
	resp, err := c.doRequest(req)
	if err != nil {
		return fmt.Errorf("hipchat request failed: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()
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
	id   string
	url  *url.URL
	desc string
	s    HipchatAccessTokenStore
}

func newHipchatAddonHandler(
	id string,
	url *url.URL,
	webhookURL *url.URL,
	prefix string,
	s HipchatAccessTokenStore,
) (*hipchatAddonHandler, error) {
	data := struct {
		AddonID    string
		AddonURL   string
		WebhookURL string
		Pattern    string
	}{
		id,
		url.String(),
		webhookURL.String(),
		"^" + prefix,
	}
	var buf bytes.Buffer
	if err := descriptorTmpl.Execute(&buf, data); err != nil {
		return nil, err
	}
	return &hipchatAddonHandler{id, url, buf.String(), s}, nil
}

func (h *hipchatAddonHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method == "GET" && req.URL.Path == h.url.Path {
		req.Header.Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(h.desc))
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
			_, _ = w.Write([]byte(err.Error()))
			return
		}
		if err := h.s.Set(data.OAuthID, data.OAuthSecret); err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			// TODO(sr) Log this but do not return it to the client
			_, _ = w.Write([]byte(err.Error()))
			return
		}
		return
	}
	w.WriteHeader(http.StatusNotFound)
}
