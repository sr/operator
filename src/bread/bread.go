package bread

import (
	"database/sql"
	"net/http"
	"net/url"

	"golang.org/x/net/context"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
)

const (
	HipchatHost = "https://hipchat.dev.pardot.com"
	TestingRoom = 882 // BREAD Testing
	PublicRoom  = 42  // Build & Automate
)

func NewLogger() operator.Logger {
	return operator.NewLogger()
}

func NewHTTPLoggerHandler(l operator.Logger, h http.Handler) http.Handler {
	return &wrapperHandler{l, h}
}

func NewLDAPAuthorizer() operator.Authorizer {
	return newLDAPAuthorizer()
}

func NewHipchatClient(config *operatorhipchat.ClientConfig) (operator.ChatClient, error) {
	return operatorhipchat.NewClient(context.Background(), config)
}

func NewHipchatClientCredentialsStore(db *sql.DB) operatorhipchat.ClientCredentialsStore {
	return operatorhipchat.NewSQLClientCredentialsStore(db)
}

func NewHipchatAddonHandler(
	id string,
	addonURL string,
	webhookURL string,
	s operatorhipchat.ClientCredentialsStore,
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
