/*
Package protolog_glog defines functionality for integration with glog.
*/
package protolog_glog // import "go.pedge.io/protolog/glog"

import (
	"flag"

	"go.pedge.io/protolog"
)

var (
	// DefaultTextMarshaller is the default text Marshaller for glog.
	DefaultTextMarshaller = protolog.NewTextMarshaller(
		protolog.TextMarshallerDisableTime(),
		protolog.TextMarshallerDisableLevel(),
	)
)

// PusherOption is an option for constructing a new Pusher.
type PusherOption func(*pusher)

// PusherWithMarshaller uses the Marshaller for the Pusher.
//
// By default, DefaultTextMarshaller is used.
func PusherWithMarshaller(marshaller protolog.Marshaller) PusherOption {
	return func(pusher *pusher) {
		pusher.marshaller = marshaller
	}
}

// NewPusher constructs a new Pusher that pushes to glog.
//
// Note that glog is only global, so two glog Pushers push to the same source.
// If using glog, it is recommended register one glog Pusher as the global protolog.Logger.
func NewPusher(options ...PusherOption) protolog.Pusher {
	return newPusher(options...)
}

// LogToStderr sets the -logtostderr flag.
func LogToStderr() error {
	return flag.Set("logtostderr", "true")
}

// AlsoLogToStderr sets the -alsologtostderr flag.
func AlsoLogToStderr() error {
	return flag.Set("alsologtostderr", "true")
}
