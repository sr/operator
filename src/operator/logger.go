package operator

import (
	"os"

	"github.com/golang/protobuf/proto"

	"go.pedge.io/protolog"
)

type logger struct {
	delegate protolog.Logger
}

func newLogger() *logger {
	return &logger{protolog.NewLogger(
		protolog.NewDefaultTextWritePusher(
			protolog.NewFileFlusher(os.Stderr),
		),
		protolog.LoggerOptions{},
	)}
}

func (l *logger) Error(message proto.Message) {
	l.delegate.Error(message)
}

func (l *logger) Info(message proto.Message) {
	l.delegate.Info(message)
}
