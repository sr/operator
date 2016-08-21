package operatorhipchat

import (
	"database/sql"
	"net/http"
	"net/url"

	"github.com/sr/operator"
	"golang.org/x/net/context"
)

var DefaultScopes = []string{"send_message", "send_notification"}

type ClientCredentialsStore interface {
	GetByAddonID(string) (*ClientCredentials, error)
	GetByOAuthID(string) (*ClientCredentials, error)
	PutByAddonID(string, *ClientCredentials) error
}

type AddonConfig struct {
	ID                string
	Name              string
	Key               string
	URL               *url.URL
	Homepage          string
	WebhookURL        *url.URL
	WebhookPrefix     string
	APIConsumerScopes []string
}

type ClientConfig struct {
	Hostname    string
	Token       string
	Credentials *ClientCredentials
	Scopes      []string
}

type ClientCredentials struct {
	ID     string
	Secret string
}

func NewClient(ctx context.Context, config *ClientConfig) (operator.ChatClient, error) {
	return newClient(ctx, config)
}

func NewAddonHandler(store ClientCredentialsStore, config *AddonConfig) (http.Handler, error) {
	return newAddonHandler(store, config)
}

func NewRequestDecoder(store ClientCredentialsStore) operator.RequestDecoder {
	return newRequestDecoder(store)
}

func NewSQLClientCredentialsStore(db *sql.DB) ClientCredentialsStore {
	return newSQLClientCredentialsStore(db)
}
