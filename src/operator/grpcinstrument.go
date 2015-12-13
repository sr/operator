package operator

import (
	"github.com/sr/operator/src/grpcinstrument"
	"go.pedge.io/protolog"
)

type grpcLogger struct {
	logger protolog.Logger
}

func newGRPCLogger(logger protolog.Logger) *grpcLogger {
	return &grpcLogger{logger}
}

func (l *grpcLogger) Log(call *grpcinstrument.Call) {
	l.logger.Info(call)
}
