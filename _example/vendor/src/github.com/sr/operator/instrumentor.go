package operator

import "github.com/sr/grpcinstrument"

type instrumentor struct {
	logger   Logger
	measurer grpcinstrument.Measurer
}

func newInstrumentor(
	logger Logger,
	measurer grpcinstrument.Measurer,
) *instrumentor {
	return &instrumentor{
		logger,
		measurer,
	}
}

func (i *instrumentor) Init() error {
	return i.measurer.Init()
}

func (i *instrumentor) Instrument(request *Request) {
	if request.Call.IsError() {
		i.logger.Error(request)
	} else {
		i.logger.Info(request)
	}
	i.measurer.Measure(request.Call)
}
