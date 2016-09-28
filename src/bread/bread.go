package bread

import (
	"database/sql"
	"errors"
	"net/http"
	"os"
	"time"

	"github.com/GeertJohan/yubigo"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecr"
	"github.com/aws/aws-sdk-go/service/ecs"
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

var (
	ACL = []*ACLEntry{
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

	DeployTargets = map[string]*DeployTarget{
		"canoe": {
			BambooProject: "BREAD",
			BambooPlan:    "BREAD",
			BambooJob:     "CAN",
			ECSCluster:    "canoe_production",
			ECSService:    "canoe",
			Image:         "build/bread/canoe/app",
		},
		"hal9000": {
			BambooProject: "BREAD",
			BambooPlan:    "BREAD",
			BambooJob:     "HAL",
			ECSCluster:    "hal9000_production",
			ECSService:    "hal9000",
			Image:         "build/bread/hal9000/app",
		},
		"operator": {
			BambooProject: "BREAD",
			BambooPlan:    "BREAD",
			BambooJob:     "OP",
			ECSCluster:    "operator_production",
			ECSService:    "operator",
			Image:         "build/bread/operatord/app",
		},
		"parbot": {
			BambooProject: "BREAD",
			BambooPlan:    "PAR",
			BambooJob:     "",
			ECSCluster:    "parbot_production",
			ECSService:    "parbot",
			Image:         "build/bread/parbot/app",
		},
		"teampass": {
			BambooProject: "BREAD",
			BambooPlan:    "BREAD",
			BambooJob:     "TEAM",
			ECSCluster:    "teampass",
			ECSService:    "teampass",
			Image:         "build/bread/tempass/app",
		},
	}
)

type OTPVerifier interface {
	Verify(otp string) error
}

type ACLEntry struct {
	Call  *operator.Call
	Group string
	OTP   bool
}

type DeployConfig struct {
	ArtifactoryAPIKey   string
	ArtifactoryURL      string
	ArtifactoryUsername string
	ArtifactoryRepo     string
	ECSTimeout          time.Duration
	AWSRegion           string
	Targets             map[string]*DeployTarget
}

type DeployTarget struct {
	BambooProject string
	BambooPlan    string
	BambooJob     string
	ECSCluster    string
	ECSService    string
	Image         string
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
	deploy *DeployConfig,
) (*grpc.Server, error) {
	server := grpc.NewServer(grpc.UnaryInterceptor(operator.NewUnaryServerInterceptor(auth, inst)))
	breadpb.RegisterPingerServer(server, &pingAPIServer{repl})
	if len(deploy.Targets) != 0 &&
		deploy.ArtifactoryURL != "" &&
		deploy.ArtifactoryUsername != "" &&
		deploy.ArtifactoryAPIKey != "" &&
		deploy.ArtifactoryRepo != "" &&
		deploy.AWSRegion != "" {
		sess := session.New(&aws.Config{Region: aws.String(deploy.AWSRegion)})
		breadpb.RegisterDeployServer(server, &deployAPIServer{
			repl,
			ecs.New(sess),
			ecr.New(sess),
			deploy,
		})
	}
	return server, nil
}

func NewUnaryClientInterceptor(replier operator.Replier) grpc.UnaryClientInterceptor {
	return func(
		ctx context.Context,
		meth string,
		req interface{},
		reply interface{},
		cc *grpc.ClientConn,
		invoker grpc.UnaryInvoker,
		opts ...grpc.CallOption,
	) error {
		err := invoker(ctx, meth, req, reply, cc, opts...)
		if err == nil {
			return err
		}
		r, ok := req.(operator.Requester)
		if !ok {
			return err
		}
		rr := r.GetRequest()
		if rr == nil {
			return err
		}
		src := rr.GetSource()
		if src == nil {
			return err
		}
		replier.Reply(ctx, src, rr.ReplierId, &operator.Message{
			Text: grpc.ErrorDesc(err),
			Options: operatorhipchat.MessageOptions{
				Color: "red",
			},
		})
		return err
	}
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
