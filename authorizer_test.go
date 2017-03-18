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
	auth, err := bread.NewAuthorizer(
		&bread.LDAPConfig{Addr: ldapAddr},
		canoeClient,
		[]*bread.ACLEntry{
			{
				Call: &bread.RPC{
					Package: "bread",
					Service: "Ping",
					Method:  "ping",
				},
				Group: "developers",
			},
		},
	)
	if err != nil {
		t.Fatal(err)
	}
	const validUserEmail = "srozet@salesforce.com"
	for _, tc := range []struct {
		userEmail string
		call      *bread.RPC
		authResp  *canoe.PhoneAuthenticationOK
		authErr   error
		wantErr   error
	}{
		{
			validUserEmail,
			&bread.RPC{Package: "bread", Service: "Ping", Method: "ping"},
			&canoe.PhoneAuthenticationOK{Payload: &models.BreadPhoneAuthenticationResponse{Error: false}},
			nil,
			nil,
		},
		{
			"",
			&bread.RPC{Package: "bread", Service: "Ping", Method: "ping"},
			&canoe.PhoneAuthenticationOK{Payload: &models.BreadPhoneAuthenticationResponse{Error: false}},
			nil,
			errors.New("unable to authorize request without an user email"),
		},
		{
			"unknown@salesforce.com",
			&bread.RPC{Package: "bread", Service: "Ping", Method: "ping"},
			&canoe.PhoneAuthenticationOK{Payload: &models.BreadPhoneAuthenticationResponse{Error: false}},
			nil,
			errors.New("no user matching email `unknown@salesforce.com`"),
		},
		{
			validUserEmail,
			&bread.RPC{Package: "bread", Service: "Ping", Method: "not-found-method"},
			&canoe.PhoneAuthenticationOK{Payload: &models.BreadPhoneAuthenticationResponse{Error: false}},
			nil,
			errors.New("no ACL entry found for service `bread.Ping not-found-method`"),
		},
		{
			validUserEmail,
			&bread.RPC{Package: "bread", Service: "Ping", Method: "ping"},
			&canoe.PhoneAuthenticationOK{Payload: &models.BreadPhoneAuthenticationResponse{Error: true}},
			nil,
			errors.New("Salesforce Authenticator verification failed"),
		},
		{
			validUserEmail,
			&bread.RPC{Package: "bread", Service: "Ping", Method: "ping"},
			&canoe.PhoneAuthenticationOK{Payload: &models.BreadPhoneAuthenticationResponse{Error: true, Message: "boomtown"}},
			nil,
			errors.New("boomtown"),
		},
		{
			validUserEmail,
			&bread.RPC{Package: "bread", Service: "Ping", Method: "ping"},
			nil,
			errors.New("canoe RPC error"),
			errors.New("Salesforce Authenticator verification failed due to an internal server error"),
		},
	} {
		canoeClient.authErr = tc.authErr
		canoeClient.authResp = tc.authResp
		if err := auth.Authorize(context.Background(), tc.call, tc.userEmail); err == nil {
			if tc.wantErr != nil {
				t.Errorf("RPC %+v by user %+v should not be authorized", tc.call, tc.userEmail)
			}
		} else {
			if tc.wantErr == nil {
				t.Errorf("RPC %+v want error: %s, got %+v", tc.call, tc.wantErr, err)
			} else if !strings.Contains(err.Error(), tc.wantErr.Error()) {
				t.Errorf("RPC %+v want error message to contain %+v, got %+v", tc.call, tc.wantErr.Error(), err.Error())
			}
		}
	}
}
