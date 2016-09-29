package bread_test

import (
	"bread"
	"errors"
	"flag"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/go-ldap/ldap"
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

var ldapEnabled bool

func init() {
	flag.BoolVar(&ldapEnabled, "ldap", false, "")
	flag.Parse()
}

type fakeOTPVerifier struct {
	ok bool
}

func (v *fakeOTPVerifier) Verify(otp string) error {
	if !v.ok {
		return errors.New("boomtown")
	}
	return nil
}

func (v *fakeOTPVerifier) fail() {
	v.ok = false
}

func TestAuthorizer(t *testing.T) {
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
	var (
		i    int
		conn *ldap.Conn
		err  error
	)
	for {
		conn, err = ldap.Dial("tcp", fmt.Sprintf("%s:%s", host, port))
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
	otpVerifier := &fakeOTPVerifier{true}
	auth, err := bread.NewAuthorizer(conn, bread.LDAPBase, otpVerifier)
	if err != nil {
		t.Fatal(err)
	}
	swe := "srozet@salesforce.com" // yubiKeyId: ccccccdluefe
	noYubiKey := "mlockhart@salesforce.com"
	unknown := "boom@gmail.com"
	validOTP := "ccccccdluefelbvvgdbehnlutdbbnnfgggvgbbjcdltu"
	for _, tc := range []struct {
		user    string
		service string
		method  string
		otp     string
		otpOK   bool
		err     error
	}{
		{swe, "bread.Ping", "Ping", "", true, nil},
		{swe, "bread.Ping", "PingPong", "", true, nil},
		{swe, "bread.Ping", "Whoami", "", true, nil},
		{"", "bread.Ping", "Ping", "", true, errors.New("unable to authorize request without an user email")},
		{swe, "bread.Ping", "Pong", "", true, errors.New("no ACL entry found for command `bread.Ping Pong`")},
		{unknown, "bread.Ping", "Ping", "", true, errors.New("no user matching email `boom@gmail.com`")},
		{swe, "bread.Ping", "Otp", validOTP, true, nil},
		{noYubiKey, "bread.Ping", "Otp", validOTP, true, fmt.Errorf("user `%s` does not have a Yubikey ID", noYubiKey)},
		{swe, "bread.Ping", "Otp", "", true, errors.New("command `bread.Ping Otp` requires a Yubikey OTP")},
		{swe, "bread.Ping", "Otp", validOTP, false, errors.New("could not verify Yubikey OTP: boomtown")},
		{swe, "bread.Ping", "Otp", "garbage", true, errors.New("could not verify Yubikey OTP: boomtown")},
	} {
		if !tc.otpOK {
			otpVerifier.fail()
		}
		err := auth.Authorize(context.Background(), &operator.Request{
			Call: &operator.Call{
				Service: tc.service,
				Method:  tc.method,
			},
			Otp: tc.otp,
			Source: &operator.Source{
				Type: operator.SourceType_HUBOT,
				User: &operator.User{
					Email: tc.user,
				},
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
