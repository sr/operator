package chatops

import "github.com/sr/operator"

type ldapAuthorizer struct{}

func (a *ldapAuthorizer) Authorize(source *operator.Request) error {
	return nil
}
