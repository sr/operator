package bread

import "github.com/sr/operator"

func NewLDAPAuthorizer() operator.Authorizer {
	return &ldapAuthorizer{}
}
