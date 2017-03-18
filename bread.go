package bread

import (
	"errors"
	"net/url"
	"strings"
	"time"

	httptransport "github.com/go-openapi/runtime/client"
	"github.com/go-openapi/strfmt"
	"github.com/golang/protobuf/jsonpb"
	"github.com/golang/protobuf/ptypes"
	"github.com/sr/operator"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"git.dev.pardot.com/Pardot/bread/pb"
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

// Logger is a logger that implements a subset of the log.Logger interface.
type Logger interface {
	Printf(format string, v ...interface{})
	Println(v ...interface{})
}

type CanoeClient interface {
	CreateDeploy(*canoe.CreateDeployParams) (*canoe.CreateDeployOK, error)
	UnlockTerraformProject(*canoe.UnlockTerraformProjectParams) (*canoe.UnlockTerraformProjectOK, error)
	PhoneAuthentication(*canoe.PhoneAuthenticationParams) (*canoe.PhoneAuthenticationOK, error)
	CreateTerraformDeploy(*canoe.CreateTerraformDeployParams) (*canoe.CreateTerraformDeployOK, error)
	CompleteTerraformDeploy(*canoe.CompleteTerraformDeployParams) (*canoe.CompleteTerraformDeployOK, error)
}

// NewCanoeClient returns a client for talking to the Canoe API. This uses the
// client generated via swagger.
func NewCanoeClient(url *url.URL, token string) CanoeClient {
	tr := httptransport.New(url.Host, "", []string{url.Scheme})
	if token != "" {
		tr.DefaultAuthentication = httptransport.APIKeyAuth("X-Api-Token", "header", token)
	}
	return canoe.New(tr, strfmt.Default)
}

// NewUnaryServerInterceptor returns a gRPC server interceptor that logs requests and authorizes requests.
func NewUnaryServerInterceptor(logger Logger, jsonpbm *jsonpb.Marshaler, authorizer Authorizer) grpc.UnaryServerInterceptor {
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
			return nil, errors.New("invalid RPC request")
		}
		if req.GetSource() == nil {
			return nil, errors.New("invalid RPC request")
		}
		p := strings.Split(info.FullMethod, "/")
		if len(p) != 3 || p[0] != "" || p[1] == "" || p[2] == "" {
			return nil, errors.New("invalid RPC request")
		}
		pp := strings.Split(p[0], ".")
		if len(pp) != 2 || p[0] == "" || p[1] == "" {
			return nil, errors.New("invalid RPC request")
		}
		// Authorize the request and log any error.
		call := &RPC{Package: pp[0], Service: pp[1], Method: p[2]}
		if err := authorizer.Authorize(ctx, call, req.GetUserEmail()); err != nil {
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
