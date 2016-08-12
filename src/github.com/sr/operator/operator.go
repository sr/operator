package operator

import (
	"errors"
	"flag"
	"net/http"

	"google.golang.org/grpc"

	"github.com/golang/protobuf/proto"
)

const DefaultAddress = "localhost:9000"

var ErrInvalidRequest = errors.New("invalid rpc request")

type Authorizer interface {
	Authorize(*Request) error
}

type Instrumenter interface {
	Instrument(*Request)
}

type Logger interface {
	Info(proto.Message)
	Error(proto.Message)
}

type RequestDecoder interface {
	Decode(*http.Request) (*Message, error)
}

type Invoker func(conn *grpc.ClientConn, req *Request, args map[string]string) (bool, error)

type ServerBuilder func(server *grpc.Server, flags *flag.FlagSet) (map[string]error, error)

type Config struct {
	Address string
}

type Command struct {
	name     string
	services []ServiceCommand
}

type CommandContext struct {
	Address string
	Source  *Source
	Flags   *flag.FlagSet
	Args    []string
}

type ServiceCommand struct {
	Name     string
	Synopsis string
	Methods  []MethodCommand
}

type MethodCommand struct {
	Name     string
	Synopsis string
	Flags    []*flag.Flag
	Run      func(*CommandContext) (string, error)
}

func NewCommand(name string, services []ServiceCommand) Command {
	return Command{name, services}
}

func NewLogger() Logger {
	return newLogger()
}

func NewInstrumenter(logger Logger) Instrumenter {
	return newInstrumenter(logger)
}

func NewHandler(
	logger Logger,
	instrumenter Instrumenter,
	authorizer Authorizer,
	decoder RequestDecoder,
	prefix string,
	conn *grpc.ClientConn,
	invoker Invoker,
) (http.Handler, error) {
	return newHandler(
		logger,
		instrumenter,
		authorizer,
		decoder,
		prefix,
		conn,
		invoker,
	)
}

func NewArgumentRequiredError(argument string) error {
	return &argumentRequiredError{argument}
}
