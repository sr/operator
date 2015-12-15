package operator

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/sr/operator/src/grpcinstrument"
	"go.pedge.io/proto/time"
)

type instrumentator struct {
	logger   Logger
	registry *registry
}

type registry struct {
	total    *prometheus.CounterVec
	errors   *prometheus.CounterVec
	duration *prometheus.HistogramVec
}

func newInstrumentator(logger Logger) grpcinstrument.Instrumentator {
	return &instrumentator{
		logger,
		&registry{
			total: prometheus.NewCounterVec(prometheus.CounterOpts{
				Name: "grpc_calls_total",
				Help: "Number of GRPC calls received by the server being instrumented.",
			}, []string{"service", "method"}),
			errors: prometheus.NewCounterVec(prometheus.CounterOpts{
				Name: "grpc_calls_errors",
				Help: "Number of GRPC calls that returned an error.",
			}, []string{"service", "method"}),
			duration: prometheus.NewHistogramVec(prometheus.HistogramOpts{
				Name: "grpc_calls_durations",
				Help: "Duration of GRPC calls.",
			}, []string{"service", "method"}),
		},
	}
}

func (i *instrumentator) Init() error {
	if err := prometheus.Register(i.registry.total); err != nil {
		return err
	}
	if err := prometheus.Register(i.registry.errors); err != nil {
		return err
	}
	if err := prometheus.Register(i.registry.duration); err != nil {
		return err
	}
}

func (i *instrumentator) CollectMetrics(call *grpcinstrument.Call) {
	labels := prometheus.Labels{"service": call.Service, "method": call.Method}
	i.registry.total.With(labels).Inc()
	i.registry.errors.With(labels).Inc()
	i.registry.duration.With(labels).Observe(
		float64(prototime.DurationFromProto(call.Duration).Nanoseconds()),
	)
}

func (i *instrumentator) Log(call *grpcinstrument.Call) {
	if call.IsError() {
		i.logger.Error(call)
	} else {
		i.logger.Info(call)
	}
}
