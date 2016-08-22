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

func NewHipchatCredsStore(db *sql.DB) operatorhipchat.ClientCredentialsStore {
	return operatorhipchat.NewSQLStore(db)
}

func NewHipchatAddonHandler(
	prefix string,
	namespace string,
	addonURL *url.URL,
	webhookURL *url.URL,
	store operatorhipchat.ClientCredentialsStore,
) http.Handler {
	return operatorhipchat.NewAddonHandler(
		store,
		&operatorhipchat.AddonConfig{
			Namespace:     namespace,
			URL:           addonURL,
			Homepage:      "https://git.dev.pardot.com/Pardot/bread",
			WebhookPrefix: prefix,
			WebhookURL:    webhookURL,
		},
	)
}

func NewPingHandler(db *sql.DB) http.Handler {
	return newPingHandler(db)
}
