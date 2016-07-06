package bread

import "github.com/sr/operator"

const (
	HipchatHost = "https://hipchat.dev.pardot.com"
	TestingRoom = 882 // BREAD Testing
	PublicRoom  = 42  // Build & Automate
)

func NewLDAPAuthorizer() operator.Authorizer {
	return &ldapAuthorizer{}
}
