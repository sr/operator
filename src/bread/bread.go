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

type HipchatConfig struct {
	Hostname    string
	Token       string
	OAuthID     string
	OAuthSecret string
}

type HipchatAccessTokenStore interface {
	Get() (*HipchatConfig, error)
	Set(oauthID, oauthSecret string) error
}

func NewLogger() operator.Logger {
	return operator.NewLogger()
}

func NewLDAPAuthorizer() operator.Authorizer {
	return newLDAPAuthorizer()
}

func NewHipchatClient(config *HipchatConfig) operator.ChatClient {
	return newHipchatClient(config)
}

func NewHipchatAccessTokenStore(db *sql.DB, addonID string) HipchatAccessTokenStore {
	return &hipchatAccessTokenStore{db, addonID}
}

func NewHipchatAddonHandler(
	id string,
	addonURL string,
	webhookURL string,
	s HipchatAccessTokenStore,
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
	return newHipchatAddonHandler(id, u, wu, prefix, s)
}

func NewPingHandler(db *sql.DB) http.Handler {
	return newPingHandler(db)
}
