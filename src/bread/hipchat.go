package bread

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"fmt"
	"html/template"
	"net/http"
	"net/url"

	"github.com/sr/operator/hipchat"
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

type hipchatOAuthClientStore struct {
	db *sql.DB
}

func newHipchatOAuthClientStore(db *sql.DB) *hipchatOAuthClientStore {
	return &hipchatOAuthClientStore{db}
}

func (s *hipchatOAuthClientStore) GetByOAuthID(id string) (*operatorhipchat.ClientCredentials, error) {
	var (
		oauthID     string
		oauthSecret string
	)
	row := s.db.QueryRow(`
		SELECT oauth_id, oauth_secret
		FROM hipchat_addon_installs
		WHERE oauth_id = ?`,
		id,
	)
	if err := row.Scan(&oauthID, &oauthSecret); err != nil {
		return nil, err
	}
	return &operatorhipchat.ClientCredentials{
		ID:     oauthID,
		Secret: oauthSecret,
	}, nil
}

func (s *hipchatOAuthClientStore) GetByAddonID(id string) (*operatorhipchat.ClientCredentials, error) {
	var (
		oauthID     string
		oauthSecret string
	)
	row := s.db.QueryRow(`
		SELECT oauth_id, oauth_secret
		FROM hipchat_addon_installs
		WHERE addon_id = ?`,
		id,
	)
	if err := row.Scan(&oauthID, &oauthSecret); err != nil {
		return nil, err
	}
	return &operatorhipchat.ClientCredentials{
		ID:     oauthID,
		Secret: oauthSecret,
	}, nil
}

func (s *hipchatOAuthClientStore) PutByAddonID(addonID string, client *operatorhipchat.ClientCredentials) error {
	_, err := s.db.Exec(`
		INSERT INTO hipchat_addon_installs (
			created_at,
			addon_id,
			oauth_id,
			oauth_secret
		)
		VALUES (NOW(), ?, ?, ?)`,
		addonID,
		client.ID,
		client.Secret,
	)
	return err
}

type hipchatAddonHandler struct {
	id    string
	url   *url.URL
	desc  string
	store operatorhipchat.OAuthClientStore
}

func newHipchatAddonHandler(
	id string,
	url *url.URL,
	webhookURL fmt.Stringer,
	prefix string,
	store operatorhipchat.OAuthClientStore,
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
	return &hipchatAddonHandler{id, url, buf.String(), store}, nil
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
		if err := h.store.PutByAddonID(h.id, &operatorhipchat.ClientCredentials{ID: data.OAuthID, Secret: data.OAuthSecret}); err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			// TODO(sr) Log this but do not return it to the client
			_, _ = w.Write([]byte(err.Error()))
			return
		}
		return
	}
	w.WriteHeader(http.StatusNotFound)
}
