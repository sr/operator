package bread_test

import (
	"errors"
	"flag"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/go-ldap/ldap"
	"github.com/sr/operator"
	"golang.org/x/net/context"

	"git.dev.pardot.com/Pardot/bread"
	"git.dev.pardot.com/Pardot/bread/swagger/client/canoe"
	"git.dev.pardot.com/Pardot/bread/swagger/models"
)

var ldapEnabled bool

func init() {
	flag.BoolVar(&ldapEnabled, "ldap", false, "")
	flag.Parse()
}

type fakeCanoeClient struct {
	authErr  error
	authResp *canoe.PhoneAuthenticationOK
}

func (c *fakeCanoeClient) CreateDeploy(*canoe.CreateDeployParams) (*canoe.CreateDeployOK, error) {
	panic("not implemented")
}

func (c *fakeCanoeClient) UnlockTerraformProject(*canoe.UnlockTerraformProjectParams) (*canoe.UnlockTerraformProjectOK, error) {
	panic("not implemented")
}

func (c *fakeCanoeClient) PhoneAuthentication(*canoe.PhoneAuthenticationParams) (*canoe.PhoneAuthenticationOK, error) {
	return c.authResp, c.authErr
}

func (c *fakeCanoeClient) CreateTerraformDeploy(*canoe.CreateTerraformDeployParams) (*canoe.CreateTerraformDeployOK, error) {
	panic("not implemented")
}

func (c *fakeCanoeClient) CompleteTerraformDeploy(*canoe.CompleteTerraformDeployParams) (*canoe.CompleteTerraformDeployOK, error) {
	panic("not implemented")
}

func TestLDAPAuthorizer(t *testing.T) {
	var host, port string
	if v, ok := os.LookupEnv("LDAP_PORT_389_TCP_ADDR"); ok {
		host = v
	}
	if v, ok := os.LookupEnv("LDAP_PORT_389_TCP_PORT"); ok {
		port = v
	}
	if host == "" || port == "" {
		if ldapEnabled {
			t.Fatal("ldap flag set but LDAP_PORT_389_TCP_{ADDR,PORT} not set")
		}
		t.Skip("ldap flag set but LDAP_PORT_389_TCP_{ADDR,PORT} not set")
	}
	ldapAddr := fmt.Sprintf("%s:%s", host, port)
	var (
		i    int
		conn *ldap.Conn
		err  error
	)
	for {
		conn, err = ldap.Dial("tcp", ldapAddr)
		if err != nil {
			continue
		}
		err = conn.Bind("", "")
		if err == nil {
			break
		}
		if i >= 500 {
			t.Fatal(err)
		}
		time.Sleep(1 * time.Millisecond)
		i = i + 1
	}
	defer conn.Close()
	canoeClient := &fakeCanoeClient{}
	auth, err := bread.NewAuthorizer(&bread.LDAPConfig{Addr: ldapAddr}, canoeClient, bread.ACL)
	if err != nil {
		t.Fatal(err)
	}
	swe := "srozet@salesforce.com"
	unknown := "boom@gmail.com"
	authOK := &canoe.PhoneAuthenticationOK{
		Payload: &models.BreadPhoneAuthenticationResponse{
			Error: false,
		},
	}
	for _, tc := range []struct {
		user     string
		service  string
		method   string
		authResp *canoe.PhoneAuthenticationOK
		authErr  error
		err      error
	}{
		{swe, "bread.Ping", "Ping", authOK, nil, nil},
		{"", "bread.Ping", "Ping", authOK, nil, errors.New("unable to authorize request without an user email")},
		{swe, "bread.Ping", "Pong", authOK, nil, errors.New("no ACL entry found for service `bread.Ping Pong`")},
		{unknown, "bread.Ping", "Ping", authOK, nil, errors.New("no user matching email `boom@gmail.com`")},
		{swe, "bread.Ping", "Ping", nil, errors.New("panic"), errors.New("Canoe phone authentication request failed")},
		{swe, "bread.Ping", "Ping", &canoe.PhoneAuthenticationOK{
			Payload: &models.BreadPhoneAuthenticationResponse{
				Error:   true,
				Message: "denied",
			},
		}, nil, errors.New("denied")},
	} {
		t.Run(fmt.Sprintf("%s %s", tc.service, tc.method), func(t *testing.T) {
			canoeClient.authErr = tc.authErr
			canoeClient.authResp = tc.authResp
			err := auth.Authorize(context.Background(), &operator.Request{
				Call: &operator.Call{
					Service: tc.service,
					Method:  tc.method,
				},
				Source: &operator.Source{
					Type: operator.SourceType_HUBOT,
					User: &operator.User{
						Email: tc.user,
					},
				},
			})
			if err == nil {
				if tc.err != nil {
					t.Errorf("user %#v should not be authorized", tc.user)
				}
			} else {
				if tc.err == nil {
					t.Errorf("unexpected error: %s", err)
				} else if !strings.Contains(err.Error(), tc.err.Error()) {
					t.Errorf("expected error message to contain %#v, got %#v", tc.err.Error(), err.Error())
				}
			}
		})
	}
}
