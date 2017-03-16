package breadhipchat

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"

	"git.dev.pardot.com/Pardot/bread"

	jose "github.com/square/go-jose"
	"golang.org/x/oauth2/clientcredentials"
)

// https://www.hipchat.com/docs/apiv2/webhooks#room_message
const eventRoomMessage = "room_message"

// A messagePayload is the payload sent by Hipchat for every message.
type messagePayload struct {
	Event string `json:"event"`
	Item  struct {
		Message struct {
			Message string      `json:"message"`
			From    *bread.User `json:"from"`
		} `json:"message"`
	} `json:"item"`
	Room *bread.Room `json:"room"`
}

// EventHandler is a HTTP handler that verifies the integrity of Hipchat
// webhook requests and calls MessageHandler with every message received.
func EventHandler(creds *clientcredentials.Config, handler bread.ChatMessageHandler) (http.HandlerFunc, error) {
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
			err := handler(&bread.ChatMessage{
				Text: payload.Item.Message.Message,
				Room: payload.Room,
				User: payload.Item.Message.From,
			})
			if err == nil {
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
