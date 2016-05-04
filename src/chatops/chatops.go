package chatops

import "github.com/sr/operator"

func NewLDAPAuthorizer() operator.Authorizer {
	return &ldapAuthorizer{}
}
