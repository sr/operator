package operator

import (
	"errors"
	"flag"
	"strings"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
)

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

type Sourcer interface {
	GetSource() *Source
}

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

func NewInterceptor(
	instrumenter Instrumenter,
	authorizer Authorizer,
) grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		in interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		sourcer, ok := in.(Sourcer)
		if !ok || sourcer.GetSource() == nil {
			return nil, ErrInvalidRequest
		}
		s := strings.Split(info.FullMethod, "/")
		if len(s) != 3 || s[0] != "" || s[1] == "" || s[2] == "" {
			return nil, ErrInvalidRequest
		}
		request := &Request{
			Source: sourcer.GetSource(),
			Call:   &Call{Service: s[1], Method: s[2]},
		}
		if err := authorizer.Authorize(request); err != nil {
			return nil, err
		}
		start := time.Now()
		response, err := handler(ctx, in)
		if err != nil {
			request.Call.Error = &Error{Message: err.Error()}
		}
		request.Call.Duration = ptypes.DurationProto(time.Since(start))
		instrumenter.Instrument(request)
		return response, err
	}
}

func NewArgumentRequiredError(argument string) error {
	return &argumentRequiredError{argument}
}
