package bread

import (
	"database/sql"
	"net/http"
	"net/url"

	"github.com/sr/operator"
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

func NewLogger() operator.Logger {
	return operator.NewLogger()
}

func NewLDAPAuthorizer() operator.Authorizer {
	return newLDAPAuthorizer()
}

func NewHipchatClientFromToken(token string) (ChatClient, error) {
	return newHipchatClientFromToken(token, HipchatHost), nil
}

func NewHipchatClientFromDatabase(db *sql.DB, addon_id string) (ChatClient, error) {
	return newHipchatClientFromDatabase(db, HipchatHost, addon_id)
}

func NewHipchatAddonHandler(
	id string,
	addonURL string,
	webhookURL string,
	db *sql.DB,
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
	return newHipchatAddonHandler(id, u, wu, prefix, db)
}

func NewPingHandler(db *sql.DB) http.Handler {
	return newPingHandler(db)
}
