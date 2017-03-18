package bread

import (
	"errors"
	"fmt"
	"net"
	"time"

	"github.com/go-ldap/ldap"
	"github.com/go-openapi/runtime"
	"golang.org/x/net/context"

	"git.dev.pardot.com/Pardot/bread/swagger/client/canoe"
	"git.dev.pardot.com/Pardot/bread/swagger/models"
)

const ldapTimeout = 3 * time.Second

type LDAPConfig struct {
	Addr string
	Base string
}

// A RPC is a Remote Procedure Call made against a gRPC service.
type RPC struct {
	Package string
	Service string
	Method  string
}

// An ACLEntry describes which LDAP group membership and 2FA requirements
// for RPCs.
type ACLEntry struct {
	Call              *RPC
	Group             string
	PhoneAuthOptional bool
}

// A Authorizer authorizes RPC requests.
type Authorizer interface {
	Authorize(context.Context, *RPC, string) error
}

type ldapAuthorizer struct {
	ldap  *LDAPConfig
	canoe CanoeClient
	acl   []*ACLEntry
}

// NewAuthorizer returns an Authorizer that enforces ACLs via LDAP, and Canoe
// for 2FA.
func NewAuthorizer(ldap *LDAPConfig, canoe CanoeClient, acl []*ACLEntry) (Authorizer, error) {
	if ldap.Base == "" {
		ldap.Base = LDAPBase
	}
	for _, e := range acl {
		if e.Call == nil || e.Call.Package == "" || e.Call.Service == "" || e.Call.Method == "" || e.Group == "" {
			return nil, fmt.Errorf("ACL entry is invalid: %+v", e)
		}
	}
	return &ldapAuthorizer{ldap, canoe, acl}, nil
}

func (a *ldapAuthorizer) Authorize(ctx context.Context, req *RPC, email string) error {
	if req == nil {
		return errors.New("required argument is nil: request")
	}
	if email == "" {
		return errors.New("unable to authorize request without an user email")
	}
	if req.Package == "" {
		return errors.New("required RPC field is nil: Package")
	}
	if req.Service == "" {
		return errors.New("required RPC field is nil: Service")
	}
	if req.Method == "" {
		return errors.New("required RPC field is nil: Method")
	}
	var entry *ACLEntry
	for _, e := range a.acl {
		if e.Call.Package == req.Package && e.Call.Service == req.Service && e.Call.Method == req.Method {
			entry = e
			break
		}
	}
	if entry == nil {
		return fmt.Errorf("no ACL entry found for service `%s.%s %s`", req.Package, req.Service, req.Method)
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
		return fmt.Errorf("service `%s %s` requires to be a member of LDAP group `%s`", req.Service, req.Method, entry.Group)
	}
	if !entry.PhoneAuthOptional {
		if err := authenticatePhone(a.canoe, email, "Chat command"); err != nil {
			return err
		}
	}
	return nil
}

func (a *ldapAuthorizer) getLDAPUserGroups(email string) ([]string, error) {
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

func authenticatePhone(canoeAPI CanoeClient, email, action string) error {
	resp, err := canoeAPI.PhoneAuthentication(
		canoe.NewPhoneAuthenticationParams().
			WithTimeout(CanoeTimeout).
			WithBody(&models.BreadPhoneAuthenticationRequest{
				Action:    action,
				UserEmail: email,
			}),
	)
	if err != nil || resp.Payload == nil {
		if v, ok := err.(*runtime.APIError); ok {
			return fmt.Errorf("Salesforce Authenticator verification failed due an internal server error (status %d)", v.Code)
		}
		return fmt.Errorf("Salesforce Authenticator verification failed due to an internal server error")
	}
	if resp.Payload.Error {
		if resp.Payload.Message == "" {
			return errors.New("Salesforce Authenticator verification failed for an unknown reason")
		}
		return errors.New(resp.Payload.Message)
	}
	return nil
}
