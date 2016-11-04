package bread

import (
	"database/sql"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecs"
	httptransport "github.com/go-openapi/runtime/client"
	"github.com/go-openapi/strfmt"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"github.com/sr/operator/protolog"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"bread/hal9000"
	"bread/pb"
	"bread/swagger/client/canoe"
)

const (
	HipchatHost  = "https://hipchat.dev.pardot.com"
	RepoURL      = "https://git.dev.pardot.com/Pardot/bread"
	TestingRoom  = 882 // BREAD Testing
	PublicRoom   = 42  // Build & Automate
	LDAPBase     = "dc=pardot,dc=com"
	CanoeTimeout = 30 * time.Second
)

var (
	ACL = []*ACLEntry{
		{
			Call: &operator.Call{
				Service: "bread.Ping",
				Method:  "Ping",
			},
			Group: "sysadmin",
		},
		{
			Call: &operator.Call{
				Service: "bread.Ping",
				Method:  "SlowLoris",
			},
			Group:             "sysadmin",
			PhoneAuthOptional: true,
		},
		{
			Call: &operator.Call{
				Service: "bread.Deploy",
				Method:  "ListTargets",
			},
			Group:             "sysadmin",
			PhoneAuthOptional: true,
		},
		{
			Call: &operator.Call{
				Service: "bread.Deploy",
				Method:  "ListBuilds",
			},
			Group:             "sysadmin",
			PhoneAuthOptional: true,
		},
		{
			Call: &operator.Call{
				Service: "bread.Deploy",
				Method:  "Trigger",
			},
			Group: "sysadmin",
		},
	}

	ECSDeployTargets = []*DeployTarget{
		{
			Name:          "canoe",
			Canoe:         false,
			ECSCluster:    "canoe_production",
			ECSService:    "canoe",
			ContainerName: "canoe",
			Image:         "build/bread/canoe/app",
		},
		{
			Name:          "hal9000",
			Canoe:         false,
			ECSCluster:    "operator_production",
			ECSService:    "operator",
			ContainerName: "hal9000",
			Image:         "build/bread/hal9000/app",
		},
		{
			Name:          "operator",
			Canoe:         false,
			ECSCluster:    "operator_production",
			ECSService:    "operator",
			ContainerName: "operatord",
			Image:         "build/bread/operatord/app",
		},
		{
			Name:          "parbot",
			Canoe:         false,
			ECSCluster:    "parbot_production",
			ECSService:    "parbot",
			ContainerName: "parbot",
			Image:         "build/bread/parbot/app",
		},
		{
			Name:          "refocus",
			Canoe:         false,
			ECSCluster:    "refocus_production",
			ECSService:    "refocus",
			ContainerName: "refocus",
			Image:         "build/pardot-refocus/app",
		},
		{
			Name:          "teampass",
			Canoe:         false,
			ECSCluster:    "teampass",
			ECSService:    "teampass",
			ContainerName: "teampass",
			Image:         "build/bread/teampass/app",
		},
	}
)

type CanoeClient interface {
	UnlockTerraformProject(*canoe.UnlockTerraformProjectParams) (*canoe.UnlockTerraformProjectOK, error)
	PhoneAuthentication(*canoe.PhoneAuthenticationParams) (*canoe.PhoneAuthenticationOK, error)
	CreateTerraformDeploy(*canoe.CreateTerraformDeployParams) (*canoe.CreateTerraformDeployOK, error)
	CompleteTerraformDeploy(*canoe.CompleteTerraformDeployParams) (*canoe.CompleteTerraformDeployOK, error)
}

type ACLEntry struct {
	Call              *operator.Call
	Group             string
	PhoneAuthOptional bool
}

type CanoeConfig struct {
	URL    string
	APIKey string
}

type DeployTarget struct {
	Name          string
	Canoe         bool
	ECSCluster    string
	ECSService    string
	ContainerName string
	Image         string
}

type LDAPConfig struct {
	Addr string
	Base string
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

func NewRepfixHandler(hal hal9000.RobotClient) http.Handler {
	return &repfixHandler{hal}
}

// NewHipchatHandler returns an http.Handler that handles incoming HipChat
// webhook requests.
func NewHipchatHandler(
	ctx context.Context,
	inst operator.Instrumenter,
	decoder operator.Decoder,
	sender operator.Sender,
	invoker operator.InvokerFunc,
	conn *grpc.ClientConn,
	svcInfo map[string]grpc.ServiceInfo,
	hal9000 hal9000.RobotClient,
	timeout time.Duration,
	prefix string,
	pkg string,
) (http.Handler, error) {
	re, err := regexp.Compile(fmt.Sprintf(operator.ReCommandMessage, regexp.QuoteMeta(prefix)))
	if err != nil {
		return nil, err
	}
	return &hipchat{
		ctx,
		inst,
		decoder,
		sender,
		invoker,
		conn,
		svcInfo,
		hal9000,
		timeout,
		re,
		pkg,
	}, nil
}

// NewPingHandler returns an http.Handler that implements a simple health
// check endpoint for use with ELB.
func NewPingHandler(db *sql.DB) http.Handler {
	return &pingHandler{db}
}

func NewDeployServer(sender operator.Sender, ecs Deployer, canoe Deployer, tz *time.Location) breadpb.DeployServer {
	if tz == nil {
		tz = time.UTC
	}
	return &deployAPIServer{sender, ecs, canoe, tz}
}

// NewECSDeployer returs a Deployer that deploys to AWS ECS
func NewECSDeployer(config *ECSConfig, afy *ArtifactoryConfig, targets []*DeployTarget) Deployer {
	return &ecsDeployer{
		ecs.New(
			session.New(
				&aws.Config{
					Region: aws.String(config.AWSRegion),
				},
			),
		),
		afy,
		config.Timeout,
		targets,
	}
}

// NewCanoeClient returns a client for interacting with the Canoe API
func NewCanoeClient(url *url.URL, token string) CanoeClient {
	tr := httptransport.New(url.Host, "", []string{url.Scheme})
	if token != "" {
		tr.DefaultAuthentication = httptransport.APIKeyAuth("X-Api-Token", "header", token)
	}
	return canoe.New(tr, strfmt.Default)
}

// NewCanoeDeployer returns a Deployer that deploys via Canoe
func NewCanoeDeployer(config *CanoeConfig) Deployer {
	return &canoeDeployer{&http.Client{}, config}
}

func NewServer(
	auth operator.Authorizer,
	inst operator.Instrumenter,
	sender operator.Sender,
	deploy breadpb.DeployServer,
) (*grpc.Server, error) {
	server := grpc.NewServer(grpc.UnaryInterceptor(operator.NewUnaryServerInterceptor(auth, inst)))
	breadpb.RegisterPingServer(server, &pingAPIServer{sender})
	if deploy != nil {
		breadpb.RegisterDeployServer(server, deploy)
	}
	return server, nil
}

// NewAuthorizer returns an operator.Authorizer that enforces ACLs using LDAP
// for authentication and LDAP group membership for authorization.
func NewAuthorizer(ldap *LDAPConfig, canoe CanoeClient, acl []*ACLEntry) (operator.Authorizer, error) {
	if ldap.Base == "" {
		ldap.Base = LDAPBase
	}
	for _, e := range acl {
		if e.Call == nil || e.Call.Service == "" || e.Call.Method == "" || e.Group == "" {
			return nil, fmt.Errorf("invalid ACL entry: %#v", e)
		}
	}
	return &authorizer{ldap, canoe, acl}, nil
}

// NewHipchatClient returns a client implementing a very limited subset of the
// Hipchat API V2. See: https://www.hipchat.com/docs/apiv2
func NewHipchatClient(config *operatorhipchat.ClientConfig) (operatorhipchat.Client, error) {
	return operatorhipchat.NewClient(context.Background(), config)
}
