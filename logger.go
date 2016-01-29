package operator

import (
	"github.com/golang/protobuf/proto"
	"github.com/sr/grpcinstrument"
	"go.pedge.io/protolog"
)

type logger struct {
	backend protolog.Logger
}

func newLogger() *logger {
	return &logger{protolog.DefaultLogger}
}

func (l *logger) Init() error {
	return nil
}

func (l *logger) Log(call *grpcinstrument.Call) {
	if call.IsError() {
		l.Error(call)
	} else {
		l.Info(call)
	}
}

func (l *logger) Info(message proto.Message) {
	l.backend.Info(message)
}

func (l *logger) Error(message proto.Message) {
	l.backend.Error(message)
}
