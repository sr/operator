package daemon // import "go.pedge.io/openflights/daemon"

import (
	"fmt"
	"net/http"
	"os"

	"go.pedge.io/openflights"
	"go.pedge.io/pkg/app"
	"go.pedge.io/proto/server"
	"google.golang.org/grpc"
)

// DoOptions are options for Do.
type DoOptions struct {
	GRPCGatewayModifier func(openflights.Client, http.Handler) (http.Handler, error)
}

// Do runs the daemon.
func Do(options DoOptions) error {
	client, err := openflights.NewDefaultServerClient()
	if err != nil {
		return err
	}
	if _, err := pkgapp.GetAndSetupAppEnv(); err != nil {
		return err
	}
	return protoserver.GetAndServeWithHTTP(
		func(grpcServer *grpc.Server) {
			openflights.RegisterAPIServer(grpcServer, openflights.NewAPIServer(client))
		},
		openflights.RegisterAPIHandler,
		protoserver.ServeWithHTTPOptions{
			HTTPHandlerModifier: func(httpHandler http.Handler) (http.Handler, error) {
				if options.GRPCGatewayModifier == nil {
					return httpHandler, nil
				}
				return options.GRPCGatewayModifier(client, httpHandler)
			},
		},
	)
}

// Main is Do but with errors handled.
func Main(options DoOptions) {
	if err := Do(options); err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err.Error())
		os.Exit(1)
	}
	os.Exit(0)
}
