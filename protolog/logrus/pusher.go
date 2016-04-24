package protologlogrus

import (
	"bytes"
	"encoding/json"
	"io"
	"strings"
	"unicode"

	"github.com/Sirupsen/logrus"
	"github.com/golang/protobuf/proto"
	"github.com/sr/operator/protolog"
)

var (
	levelToLogrusLevel = map[protolog.Level]logrus.Level{
		protolog.LevelDebug: logrus.DebugLevel,
		protolog.LevelInfo:  logrus.InfoLevel,
		protolog.LevelError: logrus.ErrorLevel,
	}
)

type pusher struct {
	logger  *logrus.Logger
	options PusherOptions
}

func newPusher(options PusherOptions) *pusher {
	logger := logrus.New()
	if options.Out != nil {
		logger.Out = options.Out
	}
	if options.Formatter != nil {
		logger.Formatter = options.Formatter
	}
	return &pusher{logger, options}
}

func (p *pusher) Push(entry *protolog.Entry) error {
	logrusEntry, err := p.getLogrusEntry(entry)
	if err != nil {
		return err
	}
	return p.logLogrusEntry(logrusEntry)
}

type flusher interface {
	Flush() error
}

type syncer interface {
	Sync() error
}

func (p *pusher) Flush() error {
	if p.options.Out != nil {
		if syncer, ok := p.options.Out.(syncer); ok {
			return syncer.Sync()
		} else if flusher, ok := p.options.Out.(flusher); ok {
			return flusher.Flush()
		}
	}
	return nil
}

func (p *pusher) getLogrusEntry(entry *protolog.Entry) (*logrus.Entry, error) {
	logrusEntry := logrus.NewEntry(p.logger)
	logrusEntry.Time = entry.Time
	logrusEntry.Level = levelToLogrusLevel[entry.Level]

	if entry.ID != "" {
		logrusEntry.Data["_id"] = entry.ID
	}
	for _, context := range entry.Contexts {
		if context == nil {
			continue
		}
		if err := addProtoMessage(logrusEntry, context); err != nil {
			return nil, err
		}
	}
	for key, value := range entry.Fields {
		if value != "" {
			logrusEntry.Data[key] = value
		}
	}
	// TODO(pedge): verify only one of Event, Message, WriterOutput?
	if entry.Event != nil {
		logrusEntry.Data["_event"] = proto.MessageName(entry.Event)
		if err := addProtoMessage(logrusEntry, entry.Event); err != nil {
			return nil, err
		}
	}
	if entry.Message != "" {
		logrusEntry.Message = trimRightSpace(entry.Message)
	}
	if entry.WriterOutput != nil {
		logrusEntry.Message = trimRightSpace(string(entry.WriterOutput))
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
	_, err = io.Copy(entry.Logger.Out, reader)
	return err
}

func addProtoMessage(logrusEntry *logrus.Entry, message proto.Message) error {
	m, err := getFieldsForProtoMessage(message)
	if err != nil {
		return err
	}
	for key, value := range m {
		logrusEntry.Data[key] = value
	}
	return nil
}

func getFieldsForProtoMessage(message proto.Message) (map[string]interface{}, error) {
	data, err := json.Marshal(message)
	if err != nil {
		return nil, err
	}
	buffer := bytes.NewBuffer(nil)
	if _, err := buffer.Write(data); err != nil {
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
