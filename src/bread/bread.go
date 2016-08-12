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

func NewLogger() operator.Logger {
	return operator.NewLogger()
}

func NewLDAPAuthorizer() operator.Authorizer {
	return newLDAPAuthorizer()
}

func NewHipchatClientFromToken(token string) (operator.ChatClient, error) {
	return newHipchatClientFromToken(token, HipchatHost), nil
}

func NewHipchatClientFromDatabase(db *sql.DB, addonID string) (operator.ChatClient, error) {
	return newHipchatClientFromDatabase(db, HipchatHost, addonID)
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
