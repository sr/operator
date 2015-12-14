package operator

import (
	"github.com/rcrowley/go-metrics"
	"github.com/sr/operator/src/grpcinstrument"
)

type instrumentator struct {
	logger   Logger
	registry metrics.Registry
}

func newInstrumentator(logger Logger, registry metrics.Registry) grpcinstrument.Instrumentator {
	return &instrumentator{logger, registry}
}

func (i *instrumentator) Log(call *grpcinstrument.Call) {
	if call.IsError() {
		i.logger.Error(call)
	} else {
		i.logger.Info(call)
	}
}

func (i *instrumentator) Increment(metric string) {
	metrics.GetOrRegisterCounter(metric, i.registry).Inc(1)
}
