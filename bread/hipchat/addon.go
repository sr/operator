package breadhipchat

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	heroku "github.com/cyberdelia/heroku-go/v3"
)

var DefaultScopes = []string{"send_message", "send_notification", "view_group"}

type AddonConfig struct {
	Name        string
	Key         string
	Homepage    string
	URL         string
	CallbackURL string
	WebhookURL  string
	AvatarURL   string
	HerokuApp   string
}

type addonDescriptor struct {
	Name         string             `json:"name,omitempty"`
	Key          string             `json:"key,omitempty"`
	Description  string             `json:"description,omitempty"`
	Links        *addonLinks        `json:"links,omitempty"`
	Capabilities *addonCapabilities `json:"capabilities,omitempty"`
}

type addonLinks struct {
	Homepage string `json:"homepage,omitempty"`
	Self     string `json:"self,omitempty"`
}

type addonCapabilities struct {
	Installable        *capInstallable `json:"installable,omitempty"`
	Webhook            []*capWebhook   `json:"webhook,omitempty"`
	HipchatAPIConsumer *capConsumer    `json:"hipchatApiConsumer,omitempty"`
}

type capInstallable struct {
	AllowGlobal bool   `json:"allowGlobal,omitempty"`
	AllowRoom   bool   `json:"allowRoom,omitempty"`
	CallbackURL string `json:"callbackUrl,omitempty"`
}

type capWebhook struct {
	Authentication string `json:"authentication,omitempty"`
	Event          string `json:"event,omitempty"`
	Pattern        string `json:"pattern,omitempty"`
	URL            string `json:"url,omitempty"`
}

type capConsumer struct {
	Scopes []string        `json:"scopes,omitempty"`
	Avatar *consumerAvatar `json:"avatar,omitempty"`
}

type consumerAvatar struct {
	URL   string `json:"url,omitempty"`
	URL2x string `json:"url@2x,omitempty"`
}

// AddonHandler is a HTTP handler that implements the addon installation flow:
// https://developer.atlassian.com/hipchat/guide/installation-flow/server-side-installation
func AddonHandler(heroku *heroku.Service, config *AddonConfig) (http.HandlerFunc, error) {
	if heroku == nil {
		return nil, errors.New("required argument is nil: heroku")
	}
	if config == nil {
		return nil, errors.New("required argument is nil: config")
	}
	if config.HerokuApp == "" {
		return nil, errors.New("required config field missing: HerokuApp")
	}
	if config.Name == "" {
		return nil, errors.New("required config field missing: Name")
	}
	if config.Key == "" {
		return nil, errors.New("required config field missing: Key")
	}
	if config.Homepage == "" {
		return nil, errors.New("required config field missing: Homepage")
	}
	if config.URL == "" {
		return nil, errors.New("required config field missing: URL")
	}
	if config.WebhookURL == "" {
		return nil, errors.New("required config field missing: WebhookURL")
	}
	descriptor := &addonDescriptor{
		Key:         config.Key,
		Name:        config.Name,
		Description: config.Homepage, // TODO(sr) provide a real description?
		Links: &addonLinks{
			Homepage: config.Homepage,
			Self:     config.URL,
		},
		Capabilities: &addonCapabilities{
			Installable: &capInstallable{
				AllowGlobal: true,
				AllowRoom:   false,
				CallbackURL: config.URL,
			},
			Webhook: []*capWebhook{
				{
					URL:            config.WebhookURL,
					Event:          "room_message",
					Authentication: "jwt",
				},
			},
			HipchatAPIConsumer: &capConsumer{
				Scopes: DefaultScopes,
			},
		},
	}
	if config.AvatarURL != "" {
		descriptor.Capabilities.HipchatAPIConsumer.Avatar = &consumerAvatar{
			URL: config.AvatarURL,
		}
	}
	return func(w http.ResponseWriter, req *http.Request) {
		switch req.Method {
		// Add-on installation process initiated; simply render the capabilities
		// descriptor as JSON.
		case "GET":
			data, err := json.Marshal(descriptor)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			req.Header.Set("Content-Type", "application/json")
			_, _ = w.Write(data)
		// The user has accepted the addon-on and given it permissions to receive
		// messages via webhook; the Hipchat server POSTs back with a set of OAuth
		// credentials that we store in a Heroku config variable.
		case "POST":
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
			_, err := heroku.ConfigVarUpdate(context.TODO(), config.HerokuApp, map[string]*string{
				"HIPCHAT_OAUTH_ID":     &data.OAuthID,
				"HIPCHAT_OAUTH_SECRET": &data.OAuthSecret,
			})
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			} else {
				w.WriteHeader(http.StatusCreated)
			}
		// TODO(sr) Handle DELETE (add-on uninstalled); remove HIPCHAT_OAUTH_{ID,SECRET}
		default:
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
	}, nil
}
