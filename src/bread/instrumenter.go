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

func (i *instrumenter) Instrument(ev *operator.Event) {
	ev.Request.Otp = ""
	ev.Request.ReplierId = ""
	ev.Request.Source.User.RealName = ""
	log := &OperatorRequest{
		Request: ev.Request,
		Args:    ev.Args,
	}
	if ev.Message != nil {
		log.Message = &OperatorMessage{
			Source: ev.Message.Source,
			Text:   ev.Message.Text,
			Html:   ev.Message.HTML,
		}
	}
	if ev.Error != nil {
		log.Error = ev.Error.Error()
	}
	i.logger.Info(log)
}
