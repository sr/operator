package operatorhipchat

import (
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type OAuthClientStore interface {
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

func NewRequestDecoder(store OAuthClientStore) operator.RequestDecoder {
	return newRequestDecoder(store)
}

func NewClient(ctx context.Context, config *ClientConfig) (operator.ChatClient, error) {
	return newClient(ctx, config)
}
