package operatorhipchat

import "github.com/sr/operator"

type OAuthClientStore interface {
	GetByAddonID(string) (*OAuthClient, error)
	GetByOAuthID(string) (*OAuthClient, error)
	PutByAddonID(string, *OAuthClient) error
}

type OAuthClient struct {
	ID     string
	Secret string
}

func NewRequestDecoder(store OAuthClientStore) operator.RequestDecoder {
	return newRequestDecoder(store)
}
