package operator

import (
	"errors"
	"flag"
	"net/http"

	"github.com/golang/protobuf/proto"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

const DefaultAddress = "localhost:9000"

var ErrInvalidRequest = errors.New("invalid rpc request")

type Authorizer interface {
	Authorize(context.Context, *Request) error
}

type Instrumenter interface {
	Instrument(*Request)
}

type Logger interface {
	Info(proto.Message)
	Error(proto.Message)
}

type Requester interface {
	GetRequest() *Request
}

type Decoder interface {
	Decode(context.Context, *http.Request) (*Message, string, error)
}

type Replier interface {
	Reply(context.Context, *Source, string, *Message) error
}

type Invoker func(context.Context, *grpc.ClientConn, *Request, map[string]string) (bool, error)

type ServerBuilder func(Replier, *grpc.Server, *flag.FlagSet) (map[string]error, error)

type Message struct {
	Source  *Source
	Text    string
	HTML    string
	Options interface{}
}

type Command struct {
	name     string
	services []ServiceCommand
}

type CommandContext struct {
	Address string
	Request *Request
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
	decoder Decoder,
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

func Reply(rep Replier, ctx context.Context, r Requester, msg *Message) (*Response, error) {
	req := r.GetRequest()
	if req == nil {
		return nil, errors.New("unable to reply without a request")
	}
	src := req.GetSource()
	if req == nil {
		return nil, errors.New("unable to reply to request with a source")
	}
	if msg.HTML == "" && msg.Text == "" {
		return nil, errors.New("unable to reply when neither msg.HTML or msg.Text are set")
	}
	return &Response{Message: msg.Text}, rep.Reply(ctx, src, req.ReplierId, msg)
}

func (r *Request) UserEmail() string {
	if r != nil && r.Source != nil && r.Source.User != nil {
		return r.Source.User.Email
	}
	return ""
}
