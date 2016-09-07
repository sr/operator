package operator

type instrumenter struct {
	logger Logger
}

func newInstrumenter(
	logger Logger,
) *instrumenter {
	return &instrumenter{logger}
}

func (i *instrumenter) Instrument(request *Request) {
	if request.Call.Error != "" {
		i.logger.Error(request)
	} else {
		i.logger.Info(request)
	}
}
