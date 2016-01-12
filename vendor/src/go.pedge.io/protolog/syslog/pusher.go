package protolog_syslog

import (
	"log/syslog"

	"go.pedge.io/protolog"
)

var (
	levelToLogFunc = map[protolog.Level]func(*syslog.Writer, string) error{
		protolog.LevelNone:  (*syslog.Writer).Info,
		protolog.LevelDebug: (*syslog.Writer).Debug,
		protolog.LevelInfo:  (*syslog.Writer).Info,
		protolog.LevelWarn:  (*syslog.Writer).Warning,
		protolog.LevelError: (*syslog.Writer).Err,
		protolog.LevelFatal: (*syslog.Writer).Crit,
		protolog.LevelPanic: (*syslog.Writer).Alert,
	}
)

type pusher struct {
	writer     *syslog.Writer
	marshaller protolog.Marshaller
}

func newPusher(writer *syslog.Writer, options ...PusherOption) *pusher {
	pusher := &pusher{writer, DefaultTextMarshaller}
	for _, option := range options {
		option(pusher)
	}
	return pusher
}

func (p *pusher) Flush() error {
	return nil
}

func (p *pusher) Push(entry *protolog.Entry) error {
	data, err := p.marshaller.Marshal(entry)
	if err != nil {
		return err
	}
	return levelToLogFunc[entry.Level](p.writer, string(data))
}
