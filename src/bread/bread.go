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
		"65a847db-d0f5-46ed-b68d-5f28505a66c1",
		"zIXhISzkqca4ylj16p6QqCBG2iOQCV05PJBcC4XW",
	), nil
}

func NewHipchatAddonHandler(
	id string,
	addonURL string,
	webhookURL string,
	prefix string,
) (http.Handler, error) {
	u, err := url.Parse(addonURL)
	if err != nil {
		return nil, err
	}
	wu, err := url.Parse(webhookURL)
	if err != nil {
		return nil, err
	}
	return newHipchatAddonHandler(id, u, wu, prefix)
}

func PingHandler(w http.ResponseWriter, _ *http.Request) {
	h := w.Header()
	h.Set("Content-Type", "application/json")
	_, _ = w.Write([]byte(`{"ok": true}`))
}
