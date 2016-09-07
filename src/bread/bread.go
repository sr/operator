package bread

import (
	"database/sql"
	"errors"
	"net/http"
	"net/url"

	"golang.org/x/net/context"

	"github.com/GeertJohan/yubigo"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
)

const (
	HipchatHost = "https://hipchat.dev.pardot.com"
	TestingRoom = 882 // BREAD Testing
	PublicRoom  = 42  // Build & Automate
	LDAPBase    = "dc=pardot,dc=com"
)

var ACL = []*ACLEntry{
	{
		Call: &operator.Call{
			Service: "ping",
			Method:  "ping",
		},
		Group: "sysadmin",
		OTP:   false,
	},
	{
		Call: &operator.Call{
			Service: "ping",
			Method:  "otp",
		},
		Group: "sysadmin",
		OTP:   true,
	},
	{
		Call: &operator.Call{
			Service: "ping",
			Method:  "whoami",
		},
		Group: "sysadmin",
		OTP:   false,
	},
}

type OTPVerifier interface {
	Verify(otp string) error
}

type ACLEntry struct {
	Call  *operator.Call
	Group string
	OTP   bool
}

type LDAPConfig struct {
	Address    string
	Encryption string
	Base       string
}

type YubicoConfig struct {
	ID  string
	Key string
}

type yubicoVerifier struct {
	yubico *yubigo.YubiAuth
}

func NewYubicoVerifier(config *YubicoConfig) (OTPVerifier, error) {
	auth, err := yubigo.NewYubiAuth(config.ID, config.Key)
	if err != nil {
		return nil, err
	}
	return &yubicoVerifier{auth}, nil
}

func (v *yubicoVerifier) Verify(otp string) error {
	_, ok, err := v.yubico.Verify(otp)
	if err != nil {
		return err
	}
	if !ok {
		return errors.New("TODO")
	}
	return nil
}

func NewLogger() operator.Logger {
	return operator.NewLogger()
}

func NewHTTPLoggerHandler(l operator.Logger, h http.Handler) http.Handler {
	return &wrapperHandler{l, h}
}

func NewAuthorizer(ldap *LDAPConfig, verifier OTPVerifier) (operator.Authorizer, error) {
	if ldap.Base == "" {
		ldap.Base = LDAPBase
	}
	return newAuthorizer(ldap, verifier, ACL)
}

func NewHipchatClient(config *operatorhipchat.ClientConfig) (operatorhipchat.Client, error) {
	return operatorhipchat.NewClient(context.Background(), config)
}

func NewHipchatCredsStore(db *sql.DB) operatorhipchat.ClientCredentialsStore {
	return operatorhipchat.NewSQLStore(db, HipchatHost)
}

func NewHipchatAddonHandler(
	prefix string,
	namespace string,
	addonURL *url.URL,
	webhookURL *url.URL,
	store operatorhipchat.ClientCredentialsStore,
) http.Handler {
	return operatorhipchat.NewAddonHandler(
		store,
		&operatorhipchat.AddonConfig{
			Namespace:     namespace,
			URL:           addonURL,
			Homepage:      "https://git.dev.pardot.com/Pardot/bread",
			WebhookPrefix: prefix,
			WebhookURL:    webhookURL,
		},
	)
}

func NewPingHandler(db *sql.DB) http.Handler {
	return newPingHandler(db)
}
