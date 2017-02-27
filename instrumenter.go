package bread

import (
	"git.dev.pardot.com/Pardot/bread/pb"
	"github.com/golang/protobuf/jsonpb"
	"github.com/sr/operator"
)

type instrumenter struct {
	logger  Logger
	jsonpbm *jsonpb.Marshaler
}

// NewInstrumenter returns an operator.Instrumenter that logs all RPC requests
// as protobuf/JSON encoded objects.
func NewInstrumenter(logger Logger) operator.Instrumenter {
	return &instrumenter{logger, &jsonpb.Marshaler{}}
}

func (i *instrumenter) Instrument(ev *operator.Event) {
	if ev.Request != nil {
		ev.Request.SenderId = ""
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
	jsonlog, err := i.jsonpbm.MarshalToString(log)
	if err != nil {
		i.logger.Printf("error marshaling log line: %s", err)
	}
	i.logger.Println(jsonlog)
}
