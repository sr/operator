package bread

import (
	"database/sql"
	"errors"
	"net/http"
	"os"

	"github.com/GeertJohan/yubigo"
	"github.com/go-ldap/ldap"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"github.com/sr/operator/protolog"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"bread/pb"
)

const (
	HipchatHost = "https://hipchat.dev.pardot.com"
	RepoURL     = "https://git.dev.pardot.com/Pardot/bread"
	TestingRoom = 882 // BREAD Testing
	PublicRoom  = 42  // Build & Automate
	LDAPBase    = "dc=pardot,dc=com"
)

var ACL = []*ACLEntry{
	{
		Call: &operator.Call{
			// TODO(sr) Add Package field to operator.Call struct
			Service: "ping.pinger",
			Method:  "ping",
		},
		Group: "sysadmin",
		OTP:   false,
	},
	{
		Call: &operator.Call{
			Service: "ping.pinger",
			Method:  "otp",
		},
		Group: "sysadmin",
		OTP:   true,
	},
	{
		Call: &operator.Call{
			Service: "ping.pinger",
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

type BambooConfig struct {
	Username string
	Password string
	URL      string
}

type DeployConfig struct {
	Apps            map[string]string
	AWSRegion       string
	CanoeECSService string
	Timeout         int
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
		return errors.New("OTP verification failed")
	}
	return nil
}

// NewLogger returns a logger that writes protobuf messages marshalled as JSON
// objects to stderr.
func NewLogger() protolog.Logger {
	return protolog.NewLogger(protolog.NewTextWritePusher(os.Stderr))
}

// NewInstrumenter returns an operator.Instrumenter that logs all requests.
func NewInstrumenter(logger protolog.Logger) operator.Instrumenter {
	return newInstrumenter(logger)
}

// NewHandler returns an http.Handler that logs all requests.
func NewHandler(logger protolog.Logger, handler http.Handler) http.Handler {
	return &wrapperHandler{logger, handler}
}

// NewPingHandler returns an http.Handler that implements a simple health
// check endpoint for use with ELB.
func NewPingHandler(db *sql.DB) http.Handler {
	return newPingHandler(db)
}

func NewServer(
	auth operator.Authorizer,
	inst operator.Instrumenter,
	repl operator.Replier,
	bamboo *BambooConfig,
	deploy *DeployConfig,
) (*grpc.Server, error) {
	server := grpc.NewServer(
		grpc.UnaryInterceptor(operator.NewUnaryInterceptor(auth, inst)),
	)
	bambooSrv, err := newBambooAPIServer(bamboo)
	if err != nil {
		return nil, err
	}
	if len(deploy.Apps) == 0 {
		deploy.Apps = map[string]string{
			"canoe":   "canoe_production",
			"hal9000": "hal9000_production",
		}
	}
	breadpb.RegisterPingerServer(server, newPingAPIServer(repl))
	breadpb.RegisterBambooServer(server, bambooSrv)
	breadpb.RegisterDeployServer(server, newDeployAPIServer(repl, deploy))
	return server, nil
}

// NewAuthorizer returns an operator.Authorizer that enforces ACLs for ChatOps
// commands using LDAP for authN/authZ, and verifies 2FA tokens via Yubikey's
// YubiCloud web service. See: https://developers.yubico.com/OTP/
func NewAuthorizer(conn *ldap.Conn, base string, verifier OTPVerifier) (operator.Authorizer, error) {
	if base == "" {
		base = LDAPBase
	}
	return newAuthorizer(conn, base, verifier, ACL)
}

// NewHipchatClient returns a client implementing a very limited subset of the
// Hipchat API V2. See: https://www.hipchat.com/docs/apiv2
func NewHipchatClient(config *operatorhipchat.ClientConfig) (operatorhipchat.Client, error) {
	return operatorhipchat.NewClient(context.Background(), config)
}
