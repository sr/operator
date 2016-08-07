package operator

import (
	"errors"
	"flag"
	"net/http"
	"time"

	"google.golang.org/grpc"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
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
	Decode(*http.Request) (*Request, error)
}

type MessageDispatcher interface {
	Dispatch(*Message) (bool, error)
}

type Invoker func(conn *grpc.ClientConn, call string, msg *Message) (bool, error)

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

type Handler struct {
	logger       Logger
	instrumenter Instrumenter
	authorizer   Authorizer
	decoder      RequestDecoder
	dispatcher   MessageDispatcher
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
	dispatcher MessageDispatcher,
) http.Handler {
	return &Handler{
		logger,
		instrumenter,
		authorizer,
		decoder,
		dispatcher,
	}
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	req, err := h.decoder.Decode(r)
	if err != nil {
		// TODO(sr) Log decoding error
		return
	}
	if err := h.authorizer.Authorize(req); err != nil {
		// TODO(sr) Log unauthorized error
		return
	}
	start := time.Now()
	ok, err := h.dispatcher.Dispatch(&Message{Source: req.Source, Text: "TODO"})
	if !ok {
		// TODO(sr) Log unhandled message
		return
	}
	if err != nil {
		req.Call.Error = &Error{Message: err.Error()}
	}
	req.Call.Duration = ptypes.DurationProto(time.Since(start))
	h.instrumenter.Instrument(req)
}

func NewMessageDispatcher(
	logger Logger,
	conn *grpc.ClientConn,
	prefix string,
	invoker Invoker,
) (MessageDispatcher, error) {
	return newMessageDispatcher(
		logger,
		conn,
		prefix,
		invoker,
	)
}

func NewArgumentRequiredError(argument string) error {
	return &argumentRequiredError{argument}
}
