package bread

import (
	"errors"
	"fmt"

	"github.com/go-ldap/ldap"
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

var ErrNoACL = errors.New("no ACL defined")

type ldapAuthorizer struct {
	config *LDAPConfig
	acl    map[*operator.Call]string
}

func newLDAPAuthorizer(config *LDAPConfig, acl map[*operator.Call]string) *ldapAuthorizer {
	return &ldapAuthorizer{config, acl}
}

func (a *ldapAuthorizer) Authorize(ctx context.Context, req *operator.Request) error {
	if req.UserEmail() == "" {
		return fmt.Errorf("unable to authorize request without an user email")
	}
	var group string
	for c, g := range a.acl {
		if c.Service == req.Call.Service && c.Method == req.Call.Method {
			group = g
			break
		}
	}
	if group == "" {
		return fmt.Errorf("no ACL defined for %s.%s", req.Call.Service, req.Call.Method)
	}
	groups, err := a.userGroups(req.UserEmail())
	if err != nil {
		return err
	}
	for _, g := range groups {
		if g == group {
			return nil
		}
	}
	return fmt.Errorf("user matching email `%s` is unauthorized to use this command", req.UserEmail())
}

func (a *ldapAuthorizer) userGroups(email string) ([]string, error) {
	conn, err := ldap.Dial("tcp", a.config.Address)
	if err != nil {
		return nil, err
	}
	defer conn.Close()
	if err := conn.Bind("", ""); err != nil {
		return nil, err
	}
	var uid string
	res, err := conn.Search(ldap.NewSearchRequest(
		a.config.Base,
		ldap.ScopeWholeSubtree, ldap.NeverDerefAliases, 0, 0, false,
		fmt.Sprintf("(mail=%s)", ldap.EscapeFilter(email)),
		[]string{"cn"},
		nil,
	))
	if err != nil {
		return nil, err
	}
	if len(res.Entries) > 1 {
		return nil, fmt.Errorf("found more than one user with email `%s`", email)
	}
	if len(res.Entries) == 0 {
		return nil, fmt.Errorf("no user matching email `%s`", email)
	}
	uid = res.Entries[0].GetAttributeValue("cn")
	if uid == "" {
		return nil, errors.New("got an invalid LDAP response")
	}
	res, err = conn.Search(ldap.NewSearchRequest(
		a.config.Base,
		ldap.ScopeWholeSubtree, ldap.NeverDerefAliases, 0, 0, false,
		fmt.Sprintf("(memberUid=%s)", ldap.EscapeFilter(uid)),
		[]string{"cn"},
		nil,
	))
	if err != nil {
		return nil, err
	}
	groups := []string{}
	for _, entry := range res.Entries {
		groups = append(groups, entry.GetAttributeValue("cn"))
	}
	return groups, nil
}
