package glog

import (
	"github.com/golang/glog"
	"go.pedge.io/protolog"
)

var (
	levelToLogFunc = map[protolog.Level]func(...interface{}){
		protolog.Level_LEVEL_NONE:  glog.Infoln,
		protolog.Level_LEVEL_DEBUG: glog.Infoln,
		protolog.Level_LEVEL_INFO:  glog.Infoln,
		protolog.Level_LEVEL_WARN:  glog.Warningln,
		protolog.Level_LEVEL_ERROR: glog.Errorln,
		protolog.Level_LEVEL_FATAL: glog.Errorln,
		protolog.Level_LEVEL_PANIC: glog.Errorln,
	}
)

type pusher struct {
	marshaller protolog.Marshaller
}

func newPusher(options PusherOptions) *pusher {
	marshaller := options.Marshaller
	if marshaller == nil {
		marshaller = protolog.DefaultMarshaller
	}
	return &pusher{marshaller}
}

func (p *pusher) Flush() error {
	glog.Flush()
	return nil
}

func (p *pusher) Push(goEntry *protolog.GoEntry) error {
	data, err := p.marshaller.Marshal(goEntry)
	if err != nil {
		return err
	}
	levelToLogFunc[goEntry.Level](string(data))
	return nil
}
