package bread

import "github.com/sr/operator"

type ldapAuthorizer struct{}

func newLDAPAuthorizer() operator.Authorizer {
	return &ldapAuthorizer{}
}

func (a *ldapAuthorizer) Authorize(source *operator.Request) error {
	return nil
}
