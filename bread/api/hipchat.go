package breadapi

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"

	heroku "github.com/cyberdelia/heroku-go/v3"
	jose "github.com/square/go-jose"
	"golang.org/x/net/context"
	"golang.org/x/oauth2/clientcredentials"

	"git.dev.pardot.com/Pardot/infrastructure/bread/hipchat"
)

// https://www.hipchat.com/docs/apiv2/webhooks#room_message
const eventRoomMessage = "room_message"

// A messagePayload is the payload sent by Hipchat for every message.
type messagePayload struct {
	Event string `json:"event"`
	Item  *item  `json:"item"`
}

type item struct {
	ChatMessage *message `json:"message"`
	Room        *Room    `json:"room"`
}

type message struct {
	ChatMessage string `json:"message"`
	From        *User  `json:"from"`
}

func HipchatMessenger(hipchat *breadhipchat.Client) (Messenger, error) {
	if hipchat == nil {
		return nil, errors.New("required argument is nil: hipchat")
	}
	return func(ctx context.Context, msg *ChatMessage) error {
		if msg == nil {
			return errors.New("required argument is nil: msg")
		}
		if msg.Room == nil {
			return errors.New("required msg struct field is nil: Room")
		}
		notif := &breadhipchat.RoomNotification{RoomID: int64(msg.Room.ID)}
		if msg.Color != "" {
			notif.MessageOptions = &breadhipchat.MessageOptions{Color: msg.Color}
		}
		if msg.HTML != "" {
			notif.MessageFormat = "html"
			notif.Message = msg.HTML
		} else {
			notif.MessageFormat = "text"
			notif.Message = msg.Text
		}
		return hipchat.SendRoomNotification(ctx, notif)
	}, nil
}

// HipchatEventHandler is a HTTP handler that verifies the integrity of Hipchat
// webhook requests and calls MessageHandler with every message received.
func HipchatEventHandler(hipchat *breadhipchat.Client, creds *clientcredentials.Config, handler ChatMessageHandler) (http.HandlerFunc, error) {
	if creds == nil {
		return nil, errors.New("required argument is nil: creds")
	}
	if handler == nil {
		return nil, errors.New("required argument is nil: handler")
	}
	return func(w http.ResponseWriter, req *http.Request) {
		auth := req.Header.Get("Authorization")
		if auth == "" {
			http.Error(w, "required header missing: Authorization", http.StatusBadRequest)
			return
		}
		parts := strings.Split(auth, " ")
		if len(parts) != 2 || parts[0] != "JWT" {
			http.Error(w, "malformed header: Authorization", http.StatusBadRequest)
			return
		}
		if err := verifySignature(parts[1], creds.ClientID, creds.ClientSecret); err != nil {
			http.Error(w, fmt.Sprintf("could not verify request signature: %s", err), http.StatusBadRequest)
			return
		}

		var payload messagePayload
		if err := json.NewDecoder(req.Body).Decode(&payload); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Normally we should **only** receive event_message payloads but
		// check anyway in case the integration setup is weird.
		if payload.Event == eventRoomMessage {
			if payload.Item == nil || payload.Item.ChatMessage == nil ||
				payload.Item.ChatMessage.From == nil || payload.Item.ChatMessage.From.ID == 0 {
				http.Error(w, "payload does not have a user", http.StatusBadRequest)
				return
			}
			msg := &ChatMessage{
				Text: payload.Item.ChatMessage.ChatMessage,
				Room: payload.Item.Room,
				User: payload.Item.ChatMessage.From,
			}
			// Unfortunately the payload normally does not include the sender's email
			// address so we have to get using the API.
			if payload.Item.ChatMessage.From.Email == "" && hipchat != nil {
				user, err := hipchat.GetUser(context.Background(), payload.Item.ChatMessage.From.ID)
				if err != nil {
					http.Error(w, fmt.Sprintf("error fetching user: %s", err), http.StatusBadRequest)
					return
				}
				msg.User.Email = user.Email
			}
			if err := handler(msg); err == nil {
				w.WriteHeader(http.StatusAccepted)
			} else {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
		} else {
			http.Error(w, fmt.Sprintf("unhandleable event type: %s", payload.Event), http.StatusBadRequest)
		}
	}, nil
}

// verifySignature verifies that the JWT token included in the request is valid.
func verifySignature(jwtToken string, clientID string, secretKey string) error {
	sig, err := jose.ParseSigned(jwtToken)
	if err != nil {
		return err
	}
	payload, err := sig.Verify([]byte(secretKey))
	if err != nil {
		return err
	}
	var data struct {
		Iss string
	}
	if err := json.Unmarshal([]byte(payload), &data); err != nil {
		return err
	}
	if data.Iss != clientID {
		return errors.New("OAuth client ID does not match")
	}
	return nil
}

type HipchatAddonConfig struct {
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

// HipchatAddonHandler is a HTTP handler that implements the Hipchat addon installation flow.
func HipchatAddonHandler(heroku *heroku.Service, config *HipchatAddonConfig) (http.HandlerFunc, error) {
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
				Scopes: breadhipchat.DefaultScopes,
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
