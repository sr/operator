package bread

import (
	"errors"
	"fmt"

	"github.com/GeertJohan/yubigo"
	"github.com/go-ldap/ldap"
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type authorizer struct {
	config   *LDAPConfig
	verifier OTPVerifier
	acl      []*ACLEntry
}

type ldapUser struct {
	groups    []string
	yubikeyID string
}

func newAuthorizer(
	config *LDAPConfig,
	verifier OTPVerifier,
	acl []*ACLEntry,
) (*authorizer, error) {
	for _, e := range acl {
		if e.Call == nil || e.Call.Service == "" || e.Call.Method == "" || e.Group == "" {
			return nil, fmt.Errorf("invalid ACL entry: %#v", e)
		}
	}
	return &authorizer{config, verifier, acl}, nil
}

func (a *authorizer) Authorize(ctx context.Context, req *operator.Request) error {
	if req.UserEmail() == "" {
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
		return fmt.Errorf("no ACL entry found for command `%s %s`", req.Call.Service, req.Call.Method)
	}
	if entry.OTP == true && req.Otp == "" {
		return fmt.Errorf("command `%s %s` requires a Yubikey OTP", req.Call.Service, req.Call.Method)
	}
	user, err := a.getLDAPUser(req.UserEmail())
	if err != nil {
		return err
	}
	ok := false
	for _, grp := range user.groups {
		if grp == entry.Group {
			ok = true
		}
	}
	if !ok {
		return fmt.Errorf("command `%s %s` requires to be a member of group `%s`", req.Call.Service, req.Call.Method, entry.Group)
	}
	if entry.OTP {
		if user.yubikeyID == "" {
			return fmt.Errorf("user `%s` does not have a Yubikey ID", req.UserEmail())
		}
		if err := a.verifier.Verify(req.Otp); err != nil {
			fmt.Printf("DEBUG yubico error: %s\n", err)
			return errors.New("could not verify given Yubikey OTP")
		}
		id, _, err := yubigo.ParseOTP(req.Otp)
		if id != user.yubikeyID || err != nil {
			if err != nil {
				fmt.Printf("DEBUG yubigo.ParseOTP error: %s\n", err)
			}
			if id != user.yubikeyID {
				fmt.Printf("DEBUG yubico id mismatch id=%s ldap-id=%s\n", id, user.yubikeyID)
			}
			return errors.New("could not verify given Yubikey OTP")
		}
	}
	return nil
}

func (a *authorizer) getLDAPUser(email string) (*ldapUser, error) {
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
		[]string{"cn", "yubiKeyId"},
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
	yubikeyID := res.Entries[0].GetAttributeValue("yubiKeyId")
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
	return &ldapUser{
		groups:    groups,
		yubikeyID: yubikeyID,
	}, nil
}
