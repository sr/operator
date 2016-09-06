package bread_test

import (
	"bread"
	"errors"
	"fmt"
	"os"
	"testing"

	"github.com/sr/operator"
	"golang.org/x/net/context"
)

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
		t.Fatal("LDAP_PORT_389_TCP_{ADDR,PORT} not set")
	}
	otpVerifier := &fakeOTPVerifier{true}
	auth, err := bread.NewAuthorizer(
		&bread.LDAPConfig{
			Address: fmt.Sprintf("%s:%s", host, port),
		},
		otpVerifier,
	)
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
		{swe, "ping", "ping", "", true, nil},
		{swe, "ping", "whoami", "", true, nil},

		{"", "ping", "ping", "", true, errors.New("unable to authorize request without an user email")},
		{swe, "ping", "pong", "", true, errors.New("no ACL entry found for command `ping pong`")},
		{unknown, "ping", "ping", "", true, errors.New("no user matching email `boom@gmail.com`")},

		{swe, "ping", "otp", validOTP, true, nil},

		{noYubiKey, "ping", "otp", validOTP, true, fmt.Errorf("user `%s` does not have a Yubikey ID", noYubiKey)},
		{swe, "ping", "otp", "", true, errors.New("command `ping otp` requires a Yubikey OTP")},
		{swe, "ping", "otp", validOTP, false, errors.New("could not verify given Yubikey OTP")},
		{swe, "ping", "otp", "garbage", true, errors.New("could not verify given Yubikey OTP")},
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
