package protolog

import (
	"bytes"
	"encoding/json"
	"strings"
	"time"
	"unicode"

	"github.com/golang/protobuf/proto"
)

type textMarshaller struct {
	options MarshallerOptions
}

func newTextMarshaller(options MarshallerOptions) *textMarshaller {
	return &textMarshaller{options}
}

func (t *textMarshaller) Marshal(goEntry *GoEntry) ([]byte, error) {
	return textMarshalGoEntry(goEntry, t.options)
}

func textMarshalGoEntry(goEntry *GoEntry, options MarshallerOptions) ([]byte, error) {
	buffer := bytes.NewBuffer(nil)
	if goEntry.ID != "" {
		_, _ = buffer.WriteString(goEntry.ID)
		_ = buffer.WriteByte(' ')
	}
	if !options.DisableTime {
		_, _ = buffer.WriteString(goEntry.Time.Format(time.RFC3339))
		_ = buffer.WriteByte(' ')
	}
	if !options.DisableLevel {
		levelString := strings.Replace(goEntry.Level.String(), "LEVEL_", "", -1)
		_, _ = buffer.WriteString(levelString)
		if len(levelString) == 4 {
			_, _ = buffer.WriteString("  ")
		} else {
			_ = buffer.WriteByte(' ')
		}
	}
	if goEntry.Event != nil {
		switch goEntry.Event.(type) {
		case *Event:
			_, _ = buffer.WriteString(goEntry.Event.(*Event).Message)
		case *WriterOutput:
			_, _ = buffer.Write(trimRightSpaceBytes(goEntry.Event.(*WriterOutput).Value))
		default:
			if err := textMarshalMessage(options.JSONMarshaller, buffer, goEntry.Event); err != nil {
				return nil, err
			}
		}
	}
	if len(goEntry.Contexts) > 0 && !options.DisableContexts {
		_, _ = buffer.WriteString(" contexts=[")
		lenContexts := len(goEntry.Contexts)
		for i, context := range goEntry.Contexts {
			switch context.(type) {
			case *Fields:
				data, err := json.Marshal(context.(*Fields).Value)
				if err != nil {
					return nil, err
				}
				_, _ = buffer.Write(data)
			default:
				if err := textMarshalMessage(options.JSONMarshaller, buffer, context); err != nil {
					return nil, err
				}
			}
			if i != lenContexts-1 {
				_, _ = buffer.WriteString(", ")
			}
		}
		_ = buffer.WriteByte(']')
	}
	return trimRightSpaceBytes(buffer.Bytes()), nil
}

func textMarshalMessage(jsonMarshaller JSONMarshaller, buffer *bytes.Buffer, message proto.Message) error {
	if message == nil {
		return nil
	}
	if jsonMarshaller == nil {
		jsonMarshaller = DefaultJSONMarshaller
	}
	_, _ = buffer.WriteString(messageName(message))
	_ = buffer.WriteByte(' ')
	return jsonMarshaller.Marshal(buffer, message)
}

func trimRightSpaceBytes(b []byte) []byte {
	return bytes.TrimRightFunc(b, unicode.IsSpace)
}
