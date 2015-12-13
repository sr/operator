package operator

import (
	"github.com/sr/operator/src/grpclog"
	"go.pedge.io/protolog"
)

type logger struct {
	protolog.Logger
}

func (l *logger) Log(call *grpclog.Call) {
	l.Info(call)
}
