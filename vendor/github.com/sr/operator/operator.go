package operator

import (
	"errors"
	"flag"
	"fmt"
	"net/http"
	"regexp"
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

type Invoker interface {
	Invoke(context.Context, *Message, *Request)
}

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

const ReCommandMessage = `\A%s(?P<service>[\w|-]+)\s+(?P<method>[\w|\-]+)(?:\s+(?P<options>.*))?\z`

func NewHandler(
	ctx context.Context,
	inst Instrumenter,
	decoder Decoder,
	invoker Invoker,
	pkg string,
	prefix string,
) (http.Handler, error) {
	re, err := regexp.Compile(fmt.Sprintf(ReCommandMessage, regexp.QuoteMeta(prefix)))
	if err != nil {
		return nil, err
	}
	return &handler{
		ctx,
		inst,
		decoder,
		invoker,
		re,
		pkg,
	}, nil
}

type InvokerFunc func(context.Context, *grpc.ClientConn, *Request, string) error

func NewInvoker(
	conn *grpc.ClientConn,
	inst Instrumenter,
	sender Sender,
	f InvokerFunc,
	timeout time.Duration,
	pkg string,
	errMsgOpts interface{},
) Invoker {
	return &invoker{
		conn,
		timeout,
		inst,
		sender,
		f,
		pkg,
		errMsgOpts,
	}
}

func NewUnaryServerInterceptor(auth Authorizer, inst Instrumenter) grpc.UnaryServerInterceptor {
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
		if req.GetSource() == nil {
			return nil, ErrInvalidRequest
		}
		s := strings.Split(info.FullMethod, "/")
		if len(s) != 3 || s[0] != "" || s[1] == "" || s[2] == "" {
			return nil, ErrInvalidRequest
		}
		req.Call = &Call{Service: s[1], Method: s[2]}
		if err := auth.Authorize(ctx, req); err != nil {
			inst.Instrument(&Event{Key: "request_unauthorized", Request: req, Error: err})
			return nil, err
		}
		start := time.Now()
		resp, err := handler(ctx, in)
		if err != nil {
			req.Call.Error = err.Error()
		}
		req.Call.Duration = ptypes.DurationProto(time.Since(start))
		inst.Instrument(&Event{Key: "request_handled", Request: req, Error: err})
		return resp, err
	}
}

type Sender interface {
	Send(context.Context, *Source, string, *Message) error
}

type RequestSender struct {
	sender Sender
	req    Requester
}

func (s *RequestSender) Send(ctx context.Context, msg *Message) error {
	return Send(ctx, s.sender, s.req, msg)
}

func GetSender(s Sender, r Requester) *RequestSender {
	if s == nil || r == nil {
		return &RequestSender{}
	}
	return &RequestSender{s, r}
}

func Send(ctx context.Context, s Sender, r Requester, msg *Message) error {
	if s == nil {
		return errors.New("unable to send message without a sender")
	}
	req := r.GetRequest()
	if req == nil {
		return errors.New("unable to send a message without a request")
	}
	src := req.GetSource()
	if src == nil {
		return errors.New("unable to send a message without a request source")
	}
	if msg == nil {
		return errors.New("unable to send a nil message")
	}
	if msg.HTML == "" && msg.Text == "" {
		return errors.New("unable to send a message with neither msg.HTML or msg.Text are set")
	}
	return s.Send(ctx, src, req.SenderId, msg)
}

func Reply(ctx context.Context, s Sender, req Requester, msg *Message) (*Response, error) {
	return &Response{Message: msg.Text}, Send(ctx, s, req, msg)
}

func GetUserEmail(r Requester) string {
	if r == nil {
		return ""
	}
	req := r.GetRequest()
	if req == nil {
		return ""
	}
	return req.GetUserEmail()
}

func (req *Request) GetUserEmail() string {
	if req == nil {
		return ""
	}
	src := req.Source
	if src == nil {
		return ""
	}
	if src.User == nil {
		return ""
	}
	return src.User.Email
}
