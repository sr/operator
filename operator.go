package operator

import (
	"flag"
	"time"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
)

type Authorizer interface {
	Authorize(*Source) error
}

type Instrumenter interface {
	Instrument(*Request)
}

type Logger interface {
	Info(proto.Message)
	Error(proto.Message)
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

func NewRequest(
	source *Source,
	serviceName string,
	methodName string,
	inputType string,
	outputType string,
	err error,
	start time.Time,
) *Request {
	call := &Call{
		Service:    serviceName,
		Method:     methodName,
		InputType:  inputType,
		OutputType: outputType,
		Duration:   ptypes.DurationProto(time.Since(start)),
	}
	if err != nil {
		call.Error = &Error{Message: err.Error()}
	}
	return &Request{Source: source, Call: call}
}

func NewArgumentRequiredError(argument string) error {
	return &argumentRequiredError{argument}
}
