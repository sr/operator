package operatorhipchat

import (
	"database/sql"

	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type ClientCredentialsStore interface {
	GetByAddonID(string) (*ClientCredentials, error)
	GetByOAuthID(string) (*ClientCredentials, error)
	PutByAddonID(string, *ClientCredentials) error
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

func NewRequestDecoder(store ClientCredentialsStore) operator.RequestDecoder {
	return newRequestDecoder(store)
}

func NewClient(ctx context.Context, config *ClientConfig) (operator.ChatClient, error) {
	return newClient(ctx, config)
}

func NewSQLClientCredentialsStore(db *sql.DB) ClientCredentialsStore {
	return newSQLClientCredentialsStore(db)
}
