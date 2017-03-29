package bread

import (
	"errors"
	"strings"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

// UserEmailKey is the gRPC metadata key containing the email of the user that
// made the request.
const UserEmailKey = "user_email"

// GRPCServerInterceptor returns a grpc.UnaryServerInterceptor that enables the
// authentication and authorization of gRPC calls using the bread.Authorizer
// interface.
func GRPCServerInterceptor(auth Authorizer) grpc.UnaryServerInterceptor {
	if auth == nil {
		panic("required argument is nil: auth")
	}
	return func(ctx context.Context, in interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		p := strings.Split(info.FullMethod, "/")
		if len(p) != 3 || p[0] != "" || p[1] == "" || p[2] == "" {
			return nil, errors.New("invalid RPC request")
		}
		pp := strings.Split(p[1], ".")
		if len(pp) != 2 || pp[0] == "" || pp[1] == "" {
			return nil, errors.New("invalid RPC request")
		}
		call := &RPC{Package: pp[0], Service: pp[1], Method: p[2]}
		if err := auth.Authorize(ctx, call, emailFromContext(ctx)); err != nil {
			return nil, err
		}
		return handler(ctx, in)
	}
}

// emailFromContexts extracts the requester's email address out of the gRPC
// call metadata.
func emailFromContext(ctx context.Context) string {
	md, ok := metadata.FromContext(ctx)
	if !ok {
		return ""
	}
	v, ok := md[UserEmailKey]
	if !ok {
		return ""
	}
	if len(v) != 1 {
		return ""
	}
	return v[0]
}
