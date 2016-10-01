package bread

import (
	"bread/pb"

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
	if ev.Request != nil {
		ev.Request.Otp = ""
		ev.Request.ReplierId = ""
		if ev.Request.Source != nil && ev.Request.Source.User != nil {
			ev.Request.Source.User.RealName = ""
		}
	}
	log := &breadpb.OperatorRequest{Event: ev.Key, Request: ev.Request}
	if ev.Message != nil {
		log.Message = &breadpb.OperatorMessage{
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
