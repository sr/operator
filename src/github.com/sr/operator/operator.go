package operator

import (
	"errors"
	"flag"
	"net/http"

	"golang.org/x/net/context"

	"google.golang.org/grpc"

	"github.com/golang/protobuf/proto"
)

const DefaultAddress = "localhost:9000"

var (
	ErrInvalidRequest = errors.New("invalid rpc request")
)

type Authorizer interface {
	Authorize(*Request) error
}

type Sourcer interface {
	GetSource() *Source
}

type Message struct {
	Source  *Source
	Text    string
	HTML    string
	Options interface{}
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

type ChatClient interface {
	Reply(context.Context, *Source, *Message) error
}

type Invoker func(context.Context, *grpc.ClientConn, *Request, map[string]string) (bool, error)

type ServerBuilder func(ChatClient, *grpc.Server, *flag.FlagSet) (map[string]error, error)

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

func Reply(ctx context.Context, req Sourcer, msg *Message, chat ChatClient) (*Response, error) {
	if req.GetSource() == nil {
		return nil, errors.New("unable to reply to message without a source")
	}
	if chat == nil {
		return nil, errors.New("unable to reply without a chat client")
	}
	if msg.HTML == "" && msg.Text == "" {
		return nil, errors.New("one of msg.HTML or msg.Text must be set")
	}
	return &Response{Message: msg.Text}, chat.Reply(ctx, req.GetSource(), msg)
}
