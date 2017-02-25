package bread

import (
	"database/sql"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecs"
	httptransport "github.com/go-openapi/runtime/client"
	"github.com/go-openapi/strfmt"
	"github.com/golang/protobuf/jsonpb"
	"github.com/golang/protobuf/ptypes"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"git.dev.pardot.com/Pardot/bread/pb"
	"git.dev.pardot.com/Pardot/bread/pb/hal9000"
	"git.dev.pardot.com/Pardot/bread/swagger/client/canoe"
)

const (
	HipchatHost  = "https://hipchat.dev.pardot.com"
	RepoURL      = "https://git.dev.pardot.com/Pardot/bread"
	TestingRoom  = 882 // BREAD Testing
	PublicRoom   = 42  // Build & Automate
	LDAPBase     = "dc=pardot,dc=com"
	CanoeTimeout = 35 * time.Second
)

var (
	ACL = []*ACLEntry{
		{
			Call: &operator.Call{
				Service: "bread.Ping",
				Method:  "Ping",
			},
			Group: "developers",
		},
		{
			Call: &operator.Call{
				Service: "bread.Ping",
				Method:  "SlowLoris",
			},
			Group:             "developers",
			PhoneAuthOptional: true,
		},
		{
			Call: &operator.Call{
				Service: "bread.Deploy",
				Method:  "ListTargets",
			},
			Group:             "developers",
			PhoneAuthOptional: true,
		},
		{
			Call: &operator.Call{
				Service: "bread.Deploy",
				Method:  "ListBuilds",
			},
			Group:             "developers",
			PhoneAuthOptional: true,
		},
		{
			Call: &operator.Call{
				Service: "bread.Deploy",
				Method:  "Trigger",
			},
			Group:             "developers",
			PhoneAuthOptional: true,
		},
		{
			Call: &operator.Call{
				Service: "bread.Tickets",
				Method:  "Mine",
			},
			Group:             "developers",
			PhoneAuthOptional: true,
		},
		{
			Call: &operator.Call{
				Service: "bread.Tickets",
				Method:  "SprintStatus",
			},
			Group:             "developers",
			PhoneAuthOptional: true,
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
	CreateDeploy(*canoe.CreateDeployParams) (*canoe.CreateDeployOK, error)
	UnlockTerraformProject(*canoe.UnlockTerraformProjectParams) (*canoe.UnlockTerraformProjectOK, error)
	PhoneAuthentication(*canoe.PhoneAuthenticationParams) (*canoe.PhoneAuthenticationOK, error)
	CreateTerraformDeploy(*canoe.CreateTerraformDeployParams) (*canoe.CreateTerraformDeployOK, error)
	CompleteTerraformDeploy(*canoe.CompleteTerraformDeployParams) (*canoe.CompleteTerraformDeployOK, error)
}

// Logger is a minimal logger interface that's compatible with log.Logger from the standard library
type Logger interface {
	Printf(format string, v ...interface{})
	Println(v ...interface{})
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

// NewHandler returns an http.Handler that logs all requests.
func NewHandler(logger Logger, handler http.Handler) http.Handler {
	return &wrapperHandler{logger, &jsonpb.Marshaler{}, handler}
}

func NewRepfixHandler(hal hal9000.RobotClient) http.Handler {
	return &repfixHandler{hal}
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
func NewECSDeployer(config *ECSConfig, afy *ArtifactoryConfig, targets []*DeployTarget, canoeAPI CanoeClient) Deployer {
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
		canoeAPI,
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
func NewCanoeDeployer(canoeAPI CanoeClient, config *CanoeConfig) Deployer {
	return &canoeDeployer{&http.Client{}, config, canoeAPI}
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

// NewUnaryServerInterceptor returns a gRPC server interceptor that logs requests as and authorizes requests.
func NewUnaryServerInterceptor(logger Logger, jsonpbm *jsonpb.Marshaler, authorizer operator.Authorizer) grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		in interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		requester, ok := in.(interface {
			GetRequest() *operator.Request
		})
		req := requester.GetRequest()
		if !ok || req == nil {
			return nil, operator.ErrInvalidRequest
		}
		if req.GetSource() == nil {
			return nil, operator.ErrInvalidRequest
		}
		s := strings.Split(info.FullMethod, "/")
		if len(s) != 3 || s[0] != "" || s[1] == "" || s[2] == "" {
			return nil, operator.ErrInvalidRequest
		}
		req.Call = &operator.Call{Service: s[1], Method: s[2]}

		// Authorize the request and log any error.
		if err := authorizer.Authorize(ctx, req); err != nil {
			req.Call.Error = err.Error()
			logRequest(logger, jsonpbm, req.Call)
			return nil, err
		}

		// Run the actual handler and record the duration and eventual error.
		start := time.Now()
		resp, err := handler(ctx, in)
		req.Call.Duration = ptypes.DurationProto(time.Since(start))
		if err != nil {
			req.Call.Error = err.Error()
		}

		// Log the request and return the original response.
		logRequest(logger, jsonpbm, req.Call)
		return resp, err
	}
}

// logRequest logs a RPC request as a protobuf/JSON encoded event if possible
// or falls back to logging an unstructured string log message otherwise.
func logRequest(logger Logger, jsonpbm *jsonpb.Marshaler, call *operator.Call) {
	if jsonpbm != nil {
		if s, err := jsonpbm.MarshalToString(&breadpb.RPCEvent{Call: call}); err == nil {
			logger.Println(s)
			return
		}
	}
	if call.Error == "" {
		logger.Printf(`request service="%s" method="%s" duration="%s"`, call.Service, call.Method, call.Duration)
	} else {
		logger.Printf(`request service="%s" method="%s" duration="%s" err="%s"`, call.Service, call.Method, call.Duration, call.Error)
	}
}
