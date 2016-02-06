package operator

import (
	"github.com/golang/protobuf/proto"
	"github.com/sr/protolog"
)

type logger struct {
	backend protolog.Logger
}

func newLogger() *logger {
	return &logger{protolog.DefaultLogger}
}

func (l *logger) Info(message proto.Message) {
	l.backend.Info(message)
}

func (l *logger) Error(message proto.Message) {
	l.backend.Error(message)
}
