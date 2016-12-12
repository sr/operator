package bread

import (
	"errors"
	"fmt"
	"net"
	"time"

	"github.com/go-ldap/ldap"
	"github.com/go-openapi/runtime"
	"github.com/sr/operator"
	"golang.org/x/net/context"

	"bread/swagger/client/canoe"
	"bread/swagger/models"
)

const ldapTimeout = 3 * time.Second

type authorizer struct {
	ldap  *LDAPConfig
	canoe CanoeClient
	acl   []*ACLEntry
}

func (a *authorizer) Authorize(ctx context.Context, req *operator.Request) error {
	email := req.GetUserEmail()
	if email == "" {
		return fmt.Errorf("unable to authorize request without an user email")
	}
	var entry *ACLEntry
	for _, e := range a.acl {
		if e.Call.Service == req.Call.Service && e.Call.Method == req.Call.Method {
			entry = e
			break
		}
	}
	if entry == nil {
		return fmt.Errorf("no ACL entry found for service `%s %s`", req.Call.Service, req.Call.Method)
	}
	groups, err := a.getLDAPUserGroups(email)
	if err != nil {
		return err
	}
	ok := false
	for _, grp := range groups {
		if grp == entry.Group {
			ok = true
		}
	}
	if !ok {
		return fmt.Errorf("service `%s %s` requires to be a member of LDAP group `%s`", req.Call.Service, req.Call.Method, entry.Group)
	}
	if !entry.PhoneAuthOptional {
		if err := authenticatePhone(a.canoe, email, "Chat command"); err != nil {
			return err
		}
	}
	return nil
}

func authenticatePhone(canoeAPI CanoeClient, email, action string) error {
	resp, err := canoeAPI.PhoneAuthentication(
		canoe.NewPhoneAuthenticationParams().
			WithTimeout(CanoeTimeout).
			WithBody(&models.CanoePhoneAuthenticationRequest{
				Action:    action,
				UserEmail: email,
			}),
	)
	if err != nil || resp.Payload == nil {
		if v, ok := err.(*runtime.APIError); ok {
			return fmt.Errorf("Canoe phone authentication request failed with status %d", v.Code)
		}
		return fmt.Errorf("Canoe phone authentication request failed in a weird way")
	}
	if resp.Payload.Error {
		if resp.Payload.Message == "" {
			return errors.New("Canoe phone authenticated failed for unknown reason")
		}
		return errors.New(resp.Payload.Message)
	}
	return nil
}

func (a *authorizer) getLDAPUserGroups(email string) ([]string, error) {
	var conn *ldap.Conn
	c, err := net.DialTimeout("tcp", a.ldap.Addr, ldapTimeout)
	if err != nil {
		return nil, err
	}
	defer func() { _ = c.Close() }()
	conn = ldap.NewConn(c, false)
	conn.SetTimeout(ldapTimeout)
	conn.Start()
	defer conn.Close()
	if err := conn.Bind("", ""); err != nil {
		return nil, err
	}
	var uid string
	res, err := conn.Search(ldap.NewSearchRequest(
		a.ldap.Base,
		ldap.ScopeWholeSubtree, ldap.NeverDerefAliases, 0, 0, false,
		fmt.Sprintf("(mail=%s)", ldap.EscapeFilter(email)),
		[]string{"cn"},
		nil,
	))
	if err != nil {
		return nil, err
	}
	if len(res.Entries) == 0 {
		return nil, fmt.Errorf("no user matching email `%s`", email)
	}
	if len(res.Entries) > 1 {
		return nil, fmt.Errorf("found more than one user matching email `%s`", email)
	}
	uid = res.Entries[0].GetAttributeValue("cn")
	if uid == "" {
		return nil, errors.New("received an invalid response from the LDAP server")
	}
	res, err = conn.Search(ldap.NewSearchRequest(
		a.ldap.Base,
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
