package bread

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
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
				"send_notification"
			]
		}
	}
}
`

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
