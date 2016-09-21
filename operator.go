package operator

import (
	"errors"
	"flag"
	"net/http"
	"strings"
	"time"

	"github.com/golang/protobuf/ptypes"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

const DefaultAddress = "localhost:9000"

var ErrInvalidRequest = errors.New("invalid rpc request")

type Authorizer interface {
	Authorize(context.Context, *Request) error
}

type Instrumenter interface {
	Instrument(*Event)
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

type Invoker func(context.Context, *grpc.ClientConn, *Request) (bool, error)

type Event struct {
	Key     string
	Message *Message
	Request *Request
	Error   error
}

type Message struct {
	Source  *Source
	Text    string
	HTML    string
	Options interface{} `json:"-"`
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

func NewHandler(
	instrumenter Instrumenter,
	decoder Decoder,
	prefix string,
	conn *grpc.ClientConn,
	invoker Invoker,
) (http.Handler, error) {
	return newHandler(
		instrumenter,
		decoder,
		prefix,
		conn,
		invoker,
	)
}

func NewUnaryInterceptor(auth Authorizer, inst Instrumenter) grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		in interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		requester, ok := in.(interface {
			GetRequest() *Request
		})
		req := requester.GetRequest()
		if !ok || req == nil {
			return nil, ErrInvalidRequest
		}
		s := strings.Split(info.FullMethod, "/")
		if len(s) != 3 || s[0] != "" || s[1] == "" || s[2] == "" {
			return nil, ErrInvalidRequest
		}
		req.Call = &Call{
			Service: strings.ToLower(s[1]),
			Method:  strings.ToLower(s[2]),
		}
		if err := auth.Authorize(ctx, req); err != nil {
			inst.Instrument(&Event{Key: "unauthorized_request", Request: req, Error: err})
			return nil, err
		}
		start := time.Now()
		resp, err := handler(ctx, in)
		if err != nil {
			req.Call.Error = err.Error()
		}
		req.Call.Duration = ptypes.DurationProto(time.Since(start))
		inst.Instrument(&Event{Key: "completed_request", Request: req, Error: err})
		return resp, err
	}
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
