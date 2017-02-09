package operatorhipchat

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
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
			{{ if .AvatarURL }}
			, "avatar": {
				"url": "{{.AvatarURL}}"
			}
			{{ end }}
		}
	}
}`))

type addonHandler struct {
	config *AddonConfig
	store  ClientCredentialsStore
}

func newAddonHandler(store ClientCredentialsStore, config *AddonConfig) *addonHandler {
	if config.APIConsumerScopes == nil {
		config.APIConsumerScopes = DefaultScopes
	}
	return &addonHandler{config, store}
}

func (h *addonHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method == "GET" && req.URL.Path == h.config.URL.Path {
		var name, key, avatarURL string
		name = req.URL.Query().Get("name")
		key = req.URL.Query().Get("key")
		avatarURL = req.URL.Query().Get("avatar")
		if name == "" {
			w.WriteHeader(http.StatusBadRequest)
			_, _ = w.Write([]byte("name query param is required\n"))
			return
		}
		if key == "" {
			w.WriteHeader(http.StatusBadRequest)
			_, _ = w.Write([]byte("key query param is required\n"))
			return
		}
		scopes := make([]string, len(h.config.APIConsumerScopes))
		for i, s := range h.config.APIConsumerScopes {
			scopes[i] = fmt.Sprintf(`"%s"`, s)
		}
		data := struct {
			Name       string
			Key        string
			URL        string
			Homepage   string
			WebhookURL string
			AvatarURL  string
			Pattern    string
			Scopes     string
		}{
			name,
			fmt.Sprintf("%s.%s", h.config.Namespace, key),
			fmt.Sprintf("%s?%s", h.config.URL, req.URL.Query().Encode()),
			h.config.Homepage,
			h.config.WebhookURL.String(),
			avatarURL,
			"^" + h.config.WebhookPrefix,
			strings.Join(scopes, ", "),
		}
		var buf bytes.Buffer
		if err := descriptorTmpl.Execute(&buf, data); err != nil {
			// TODO(sr) Log the error but do not return it to the client
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		req.Header.Set("Content-Type", "application/json")
		_, _ = w.Write(buf.Bytes())
		return
	}
	if req.Method != "POST" || req.URL.Path != h.config.URL.Path {
		w.WriteHeader(http.StatusNotFound)
		return
	}
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
	if err := h.store.Create(
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
}
