package logrus

import (
	"bytes"
	"encoding/json"
	"io"
	"strings"
	"sync"
	"unicode"

	"github.com/Sirupsen/logrus"
	"github.com/golang/protobuf/proto"
	"go.pedge.io/protolog"
)

var (
	levelToLogrusLevel = map[protolog.Level]logrus.Level{
		protolog.Level_LEVEL_NONE:  logrus.InfoLevel,
		protolog.Level_LEVEL_DEBUG: logrus.DebugLevel,
		protolog.Level_LEVEL_INFO:  logrus.InfoLevel,
		protolog.Level_LEVEL_WARN:  logrus.WarnLevel,
		protolog.Level_LEVEL_ERROR: logrus.ErrorLevel,
		protolog.Level_LEVEL_FATAL: logrus.FatalLevel,
		protolog.Level_LEVEL_PANIC: logrus.PanicLevel,
	}
)

type pusher struct {
	logger  *logrus.Logger
	lock    *sync.Mutex
	options PusherOptions
}

func newPusher(options PusherOptions) *pusher {
	logger := logrus.New()
	if options.Out != nil {
		logger.Out = options.Out
	}
	if options.Hooks != nil && len(options.Hooks) > 0 {
		for _, hook := range options.Hooks {
			logger.Hooks.Add(hook)
		}
	}
	if options.Formatter != nil {
		logger.Formatter = options.Formatter
	}
	return &pusher{logger, &sync.Mutex{}, options}
}

func (p *pusher) Push(goEntry *protolog.GoEntry) error {
	logrusEntry, err := p.getLogrusEntry(goEntry)
	if err != nil {
		return err
	}
	return p.logLogrusEntry(logrusEntry)
}

func (p *pusher) Flush() error {
	if p.options.Out != nil {
		return p.options.Out.Flush()
	}
	return nil
}

func (p *pusher) getLogrusEntry(goEntry *protolog.GoEntry) (*logrus.Entry, error) {
	jsonMarshaller := p.options.JSONMarshaller
	if jsonMarshaller == nil {
		jsonMarshaller = protolog.DefaultJSONMarshaller
	}
	logrusEntry := logrus.NewEntry(p.logger)
	logrusEntry.Time = goEntry.Time
	logrusEntry.Level = levelToLogrusLevel[goEntry.Level]

	if goEntry.ID != "" {
		logrusEntry.Data["_id"] = goEntry.ID
	}
	if !p.options.DisableContexts {
		for _, context := range goEntry.Contexts {
			if context == nil {
				continue
			}
			switch context.(type) {
			case *protolog.Fields:
				for key, value := range context.(*protolog.Fields).Value {
					if value != "" {
						logrusEntry.Data[key] = value
					}
				}
			default:
				if err := addProtoMessage(jsonMarshaller, logrusEntry, context); err != nil {
					return nil, err
				}
			}
		}
	}
	if goEntry.Event != nil {
		switch goEntry.Event.(type) {
		case *protolog.Event:
			logrusEntry.Message = trimRightSpace(goEntry.Event.(*protolog.Event).Message)
		case *protolog.WriterOutput:
			logrusEntry.Message = trimRightSpace(string(goEntry.Event.(*protolog.WriterOutput).Value))
		default:
			logrusEntry.Data["_event"] = proto.MessageName(goEntry.Event)
			if err := addProtoMessage(jsonMarshaller, logrusEntry, goEntry.Event); err != nil {
				return nil, err
			}
		}
	}
	return logrusEntry, nil
}

func (p *pusher) logLogrusEntry(entry *logrus.Entry) error {
	if err := entry.Logger.Hooks.Fire(entry.Level, entry); err != nil {
		return err
	}
	reader, err := entry.Reader()
	if err != nil {
		return err
	}
	p.lock.Lock()
	defer p.lock.Unlock()
	_, err = io.Copy(entry.Logger.Out, reader)
	return err
}

func addProtoMessage(jsonMarshaller protolog.JSONMarshaller, logrusEntry *logrus.Entry, message proto.Message) error {
	m, err := getFieldsForProtoMessage(jsonMarshaller, message)
	if err != nil {
		return err
	}
	for key, value := range m {
		logrusEntry.Data[key] = value
	}
	return nil
}

func getFieldsForProtoMessage(jsonMarshaller protolog.JSONMarshaller, message proto.Message) (map[string]interface{}, error) {
	buffer := bytes.NewBuffer(nil)
	if err := jsonMarshaller.Marshal(buffer, message); err != nil {
		return nil, err
	}
	m := make(map[string]interface{}, 0)
	if err := json.Unmarshal(buffer.Bytes(), &m); err != nil {
		return nil, err
	}
	n := make(map[string]interface{}, len(m))
	for key, value := range m {
		switch value.(type) {
		case map[string]interface{}:
			data, err := json.Marshal(value)
			if err != nil {
				return nil, err
			}
			n[key] = string(data)
		default:
			n[key] = value
		}
	}
	return n, nil
}

func trimRightSpace(s string) string {
	return strings.TrimRightFunc(s, unicode.IsSpace)
}
