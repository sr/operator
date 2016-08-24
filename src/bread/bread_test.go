package bread_test

import (
	"bread"
	"errors"
	"flag"
	"fmt"
	"os"
	"testing"

	"github.com/sr/operator"
)

var ldapPort = flag.String("ldap-port", "", "")

func TestLDAPAuthorizer(t *testing.T) {
	var port string
	if *ldapPort != "" {
		port = *ldapPort
	} else {
		port = os.Getenv("LDAP_PORT_389_TCP_PORT")
	}
	if port == "" {
		t.Skip("ldap-addr not set. skipping test")
	}
	auth := bread.NewLDAPAuthorizer(&bread.LDAPConfig{
		Address: fmt.Sprintf("localhost:%s", port),
	})
	sr := "srozet@salesforce.com"
	for _, tc := range []struct {
		user    string
		service string
		method  string
		err     error
	}{
		{sr, "ping", "ping", nil},
		{"", "ping", "ping", errors.New("unable to authorize request without an user email")},
		{sr, "ping", "pong", errors.New("no ACL defined for ping.pong")},
		{"boom@gmail.com", "ping", "ping", errors.New("no user matching email `boom@gmail.com`")},
	} {
		err := auth.Authorize(&operator.Request{
			Source: &operator.Source{
				Type: operator.SourceType_HUBOT,
				User: &operator.User{
					Email: tc.user,
				},
			},
			Call: &operator.Call{
				Service: tc.service,
				Method:  tc.method,
			},
		})
		if err == nil {
			if tc.err != nil {
				t.Errorf("user %#v should not be authorized to request %s.%s", tc.user, tc.service, tc.method)
			}
		} else {
			if tc.err == nil {
				t.Fatalf("unexpected error: %s", err)
			}
			if err.Error() != tc.err.Error() {
				t.Errorf("expected error message %#v, got %#v", tc.err.Error(), err.Error())
			}
		}
	}
}
