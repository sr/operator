package operator

import (
	"github.com/sr/operator/src/grpclog"
	"go.pedge.io/protolog"
)

type grpclogLogger struct {
	logger protolog.Logger
}

func newGRPCLogger(logger protolog.Logger) *grpclogLogger {
	return &grpclogLogger{logger}
}

func (l *grpclogLogger) Log(call *grpclog.Call) {
	l.logger.Info(call)
}
