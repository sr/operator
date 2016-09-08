package bread

import (
	"github.com/sr/operator"
	"github.com/sr/operator/protolog"
)

type instrumenter struct {
	logger protolog.Logger
}

func newInstrumenter(logger protolog.Logger) *instrumenter {
	return &instrumenter{logger}
}

func (i *instrumenter) Instrument(req *operator.Request) {
	req.Otp = ""
	req.ReplierId = ""
	i.logger.Info(req)
}
