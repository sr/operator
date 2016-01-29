package operator

import (
	"github.com/sr/grpcinstrument"
	"go.pedge.io/protolog"
)

type logger struct {
	log protolog.Logger
}

func newLogger(log protolog.Logger) grpcinstrument.Logger {
	return &logger{log}
}

func (l *logger) Init() error {
	return nil
}

func (l *logger) Log(call *grpcinstrument.Call) {
	if call.IsError() {
		l.log.Error(call)
	} else {
		l.log.Info(call)
	}
}
