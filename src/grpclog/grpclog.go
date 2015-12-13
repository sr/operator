package grpclog

import (
	"time"

	"go.pedge.io/proto/time"
)

type Logger interface {
	Log(*Call)
}

func Log(
	logger Logger,
	serviceName string,
	methodName string,
	inputType string,
	outputType string,
	err error,
	start time.Time,
) {
	call := &Call{
		Service:  serviceName,
		Input:    &Input{Type: inputType},
		Output:   &Output{Type: outputType},
		Duration: prototime.DurationToProto(time.Since(start)),
	}
	if err != nil {
		call.Error = &Error{Message: err.Error()}
	}
	logger.Log(call)
}
