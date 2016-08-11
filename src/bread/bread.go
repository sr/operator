package bread

import (
	"net/http"
	"net/url"

	"github.com/sr/operator"
	"google.golang.org/grpc"
)

const (
	HipchatHost = "https://hipchat.dev.pardot.com"
	TestingRoom = 882 // BREAD Testing
	PublicRoom  = 42  // Build & Automate
)

type ChatClient interface {
	SendRoomNotification(*ChatRoomNotification) error
}

type ChatRoomNotification struct {
	Color         string `json:"color"`
	From          string `json:"from"`
	Message       string `json:"message"`
	MessageFormat string `json:"message_format"`
	RoomID        int    `json:"-"`
}

func NewOperatorServer() *grpc.Server {
	return grpc.NewServer()
}

func NewLDAPAuthorizer() operator.Authorizer {
	return newLDAPAuthorizer()
}

func NewHipchatClient(token string) (ChatClient, error) {
	return newHipchatClient(
		HipchatHost,
		token,
		// TODO(sr) Fetch this from a datastore somehow
		"410641fd-7180-48aa-a7fb-a14df80b99f0",
		"NyZtyBzKgxZKJHdS1h3Gcv8HbvvzoCvNS5JG8whu",
	), nil
}

func NewHipchatAddonHandler(id string, url *url.URL) http.Handler {
	return newHipchatAddonHandler(id, url)
}

func PingHandler(w http.ResponseWriter, _ *http.Request) {
	h := w.Header()
	h.Set("Content-Type", "application/json")
	w.Write([]byte(`{"ok": true}`))
}
