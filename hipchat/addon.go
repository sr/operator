package operatorhipchat

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"text/template"
)

var descriptorTmpl = template.Must(template.New("descriptor.json").Parse(`{
	"name": "{{.Name}}",
	"key": "{{.Key}}",
	"description": "ChatOps",
	"links": {
		"homepage": "{{.Homepage}}",
		"self": "{{.URL}}"
	},
	"capabilities": {
		"installable": {
			"allowGlobal": true,
			"allowRoom": false,
			"callbackUrl": "{{.URL}}"
		},
		"webhook": [
			{
				"url": "{{.WebhookURL}}",
				"pattern": "{{.Pattern}}",
				"event": "room_message",
				"authentication": "jwt",
				"name": "operator"
			}
		],
		"hipchatApiConsumer": {
			"scopes": [{{.Scopes}}]
		}
	}
}`))

type addonHandler struct {
	id    string
	url   *url.URL
	desc  string
	store ClientCredentialsStore
}

func newAddonHandler(store ClientCredentialsStore, config *AddonConfig) (*addonHandler, error) {
	if config.APIConsumerScopes == nil {
		config.APIConsumerScopes = DefaultScopes
	}
	scopes := make([]string, len(config.APIConsumerScopes))
	for i, s := range config.APIConsumerScopes {
		scopes[i] = fmt.Sprintf(`"%s"`, s)
	}
	data := struct {
		ID         string
		Name       string
		Key        string
		URL        string
		Homepage   string
		WebhookURL string
		Pattern    string
		Scopes     string
	}{
		config.ID,
		config.Name,
		config.Key,
		config.URL.String(),
		config.Homepage,
		config.WebhookURL.String(),
		"^" + config.WebhookPrefix,
		strings.Join(scopes, ", "),
	}
	var buf bytes.Buffer
	if err := descriptorTmpl.Execute(&buf, data); err != nil {
		return nil, err
	}
	return &addonHandler{
		config.ID,
		config.URL,
		buf.String(),
		store,
	}, nil
}

func (h *addonHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
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
		if err := h.store.PutByAddonID(
			h.id,
			&ClientCredentials{
				ID:     data.OAuthID,
				Secret: data.OAuthSecret,
			},
		); err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			// TODO(sr) Log this but do not return it to the client
			_, _ = w.Write([]byte(err.Error()))
			return
		}
		return
	}
	w.WriteHeader(http.StatusNotFound)
}
