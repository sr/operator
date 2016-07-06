package bread

import (
	"github.com/sr/operator"
	"google.golang.org/grpc"
)

const (
	HipchatHost = "https://hipchat.dev.pardot.com"
	TestingRoom = 882 // BREAD Testing
	PublicRoom  = 42  // Build & Automate
)

func NewOperatorServer(logger operator.Logger) *grpc.Server {
	return grpc.NewServer(
		grpc.UnaryInterceptor(
			operator.NewInterceptor(
				operator.NewInstrumenter(logger),
				newLDAPAuthorizer(),
			),
		),
	)
}
