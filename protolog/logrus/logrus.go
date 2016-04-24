// Package protologlogrus defines functionality for integration with Logrus.
package protologlogrus

import (
	"io"

	"github.com/Sirupsen/logrus"

	"github.com/sr/operator/protolog"
)

// PusherOptions defines options for constructing a new Logrus protolog.Pusher.
type PusherOptions struct {
	Out       io.Writer
	Formatter logrus.Formatter
}

// NewPusher creates a new protolog.Pusher that logs using Logrus.
func NewPusher(options PusherOptions) protolog.Pusher {
	return newPusher(options)
}
