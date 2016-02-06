package protologger

import (
	"github.com/sr/grpcinstrument"
	"github.com/sr/protolog"
)

// NewLogger constructs an implementation of the Logger interface that logs
// RPC calls via protolog.
func NewLogger(logger protolog.Logger) grpcinstrument.Logger {
	return newLogger(logger)
}
