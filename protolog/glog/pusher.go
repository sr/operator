package protolog_glog

import (
	"github.com/golang/glog"
	"github.com/sr/protolog"
)

var (
	levelToLogFunc = map[protolog.Level]func(...interface{}){
		protolog.LevelNone:  glog.Infoln,
		protolog.LevelDebug: glog.Infoln,
		protolog.LevelInfo:  glog.Infoln,
		protolog.LevelWarn:  glog.Warningln,
		protolog.LevelError: glog.Errorln,
		protolog.LevelFatal: glog.Errorln,
		protolog.LevelPanic: glog.Errorln,
	}
)

type pusher struct {
	marshaller protolog.Marshaller
}

func newPusher(options ...PusherOption) *pusher {
	pusher := &pusher{DefaultTextMarshaller}
	for _, option := range options {
		option(pusher)
	}
	return pusher
}

func (p *pusher) Flush() error {
	glog.Flush()
	return nil
}

func (p *pusher) Push(entry *protolog.Entry) error {
	data, err := p.marshaller.Marshal(entry)
	if err != nil {
		return err
	}
	levelToLogFunc[entry.Level](string(data))
	return nil
}
