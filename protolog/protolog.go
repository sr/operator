/*
Package protolog defines the main protolog functionality.
*/
package protolog

import (
	"fmt"
	"io"
	"os"
	"strconv"
	"time"

	"github.com/golang/protobuf/proto"
)

const (
	// LevelNone represents no Level.
	LevelNone Level = 0
	// LevelDebug is the debug Level.
	LevelDebug Level = 1
	// LevelInfo is the info Level.
	LevelInfo Level = 2
	// LevelWarn is the warn Level.
	LevelWarn Level = 3
	// LevelError is the error Level.
	LevelError Level = 4
)

var (
	// DefaultLevel is the default Level.
	DefaultLevel = LevelInfo
	// DefaultIDAllocator is the default IDAllocator.
	DefaultIDAllocator = &idAllocator{instanceID, 0}
	// DefaultTimer is the default Timer.
	DefaultTimer = &timer{}
	// DefaultErrorHandler is the default ErrorHandler.
	DefaultErrorHandler = &errorHandler{}

	// DelimitedMarshaller is a Marshaller that uses the protocol buffers write delimited scheme.
	DelimitedMarshaller = &delimitedMarshaller{}
	// DelimitedUnmarshaller is an Unmarshaller that uses the protocol buffers write delimited scheme.
	DelimitedUnmarshaller = &delimitedUnmarshaller{}

	// DiscardPusher is a Pusher that discards all logs.
	DiscardPusher = discardPusherInstance
	// DiscardLogger is a Logger that discards all logs.
	DiscardLogger = NewLogger(DiscardPusher)

	// DefaultPusher is the default Pusher.
	DefaultPusher = NewTextWritePusher(os.Stderr)
	// DefaultLogger is the default Logger.
	DefaultLogger = NewLogger(DefaultPusher)

	levelToName = map[Level]string{
		LevelNone:  "NONE",
		LevelDebug: "DEBUG",
		LevelInfo:  "INFO",
		LevelWarn:  "WARN",
		LevelError: "ERROR",
	}
	nameToLevel = map[string]Level{
		"NONE":  LevelNone,
		"DEBUG": LevelDebug,
		"INFO":  LevelInfo,
		"WARN":  LevelWarn,
		"ERROR": LevelError,
	}
)

// Level is a logging level.
type Level int32

// String returns the name of a Level or the numerical value if the Level is unknown.
func (l Level) String() string {
	name, ok := levelToName[l]
	if !ok {
		return strconv.Itoa(int(l))
	}
	return name
}

// NameToLevel returns the Level for the given name.
func NameToLevel(name string) (Level, error) {
	level, ok := nameToLevel[name]
	if !ok {
		return LevelNone, fmt.Errorf("protolog: no level for name: %s", name)
	}
	return level, nil
}

// Flusher is an object that can be flushed to a persistent store.
type Flusher interface {
	Flush() error
}

// Logger is the main logging interface.
type Logger interface {
	Flusher

	AtLevel(level Level) Logger

	WithContext(context proto.Message) Logger
	Debug(event proto.Message)
	Info(event proto.Message)
	Warn(event proto.Message)
	Error(event proto.Message)
	Print(event proto.Message)

	DebugWriter() io.Writer
	InfoWriter() io.Writer
	WarnWriter() io.Writer
	ErrorWriter() io.Writer
	Writer() io.Writer

	WithField(key string, value interface{}) Logger
	WithFields(fields map[string]interface{}) Logger
	Debugf(format string, args ...interface{})
	Debugln(args ...interface{})
	Infof(format string, args ...interface{})
	Infoln(args ...interface{})
	Warnf(format string, args ...interface{})
	Warnln(args ...interface{})
	Errorf(format string, args ...interface{})
	Errorln(args ...interface{})
	Printf(format string, args ...interface{})
	Println(args ...interface{})
}

// Entry is the go equivalent of an Entry.
type Entry struct {
	// ID may not be set depending on LoggerOptions.
	// it is up to the user to determine if ID is required.
	ID    string    `json:"id,omitempty"`
	Level Level     `json:"level,omitempty"`
	Time  time.Time `json:"time,omitempty"`
	// both Contexts and Fields may be set
	Contexts []proto.Message   `json:"contexts,omitempty"`
	Fields   map[string]string `json:"fields,omitempty"`
	// one of Event, Message, WriterOutput will be set
	Event        proto.Message `json:"event,omitempty"`
	Message      string        `json:"message,omitempty"`
	WriterOutput []byte        `json:"writer_output,omitempty"`
}

// String defaults a string representation of the Entry.
func (g *Entry) String() string {
	if g == nil {
		return ""
	}
	data, err := textMarshalEntry(g, false, false, false, true)
	if err != nil {
		return ""
	}
	return string(data)
}

// Pusher is the interface used to push Entry objects to a persistent store.
type Pusher interface {
	Flusher
	Push(entry *Entry) error
}

// IDAllocator allocates unique IDs for Entry objects. The default
// behavior is to allocate a new UUID for the process, then add an
// incremented integer to the end.
type IDAllocator interface {
	Allocate() string
}

// Timer returns the current time. The default behavior is to
// call time.Now().UTC().
type Timer interface {
	Now() time.Time
}

// ErrorHandler handles errors when logging. The default behavior
// is to panic.
type ErrorHandler interface {
	Handle(err error)
}

// LoggerOption is an option for the Logger constructor.
type LoggerOption func(*logger)

// LoggerWithIDEnabled enables IDs for the Logger.
func LoggerWithIDEnabled() LoggerOption {
	return func(logger *logger) {
		logger.enableID = true
	}
}

// LoggerWithIDAllocator uses the IDAllocator for the Logger.
func LoggerWithIDAllocator(idAllocator IDAllocator) LoggerOption {
	return func(logger *logger) {
		logger.idAllocator = idAllocator
	}
}

// LoggerWithTimer uses the Timer for the Logger.
func LoggerWithTimer(timer Timer) LoggerOption {
	return func(logger *logger) {
		logger.timer = timer
	}
}

// LoggerWithErrorHandler uses the ErrorHandler for the Logger.
func LoggerWithErrorHandler(errorHandler ErrorHandler) LoggerOption {
	return func(logger *logger) {
		logger.errorHandler = errorHandler
	}
}

// NewLogger constructs a new Logger using the given Pusher.
func NewLogger(pusher Pusher, options ...LoggerOption) Logger {
	return newLogger(pusher, options...)
}

// Marshaller marshals Entry objects to be written.
type Marshaller interface {
	Marshal(entry *Entry) ([]byte, error)
}

// WritePusherOption is an option for constructing a new write Pusher.
type WritePusherOption func(*writePusher)

// WritePusherWithMarshaller uses the Marshaller for the write Pusher.
//
// By default, DelimitedMarshaller is used.
func WritePusherWithMarshaller(marshaller Marshaller) WritePusherOption {
	return func(writePusher *writePusher) {
		writePusher.marshaller = marshaller
	}
}

// NewWritePusher constructs a new Pusher that writes to the given io.Writer.
func NewWritePusher(writer io.Writer, options ...WritePusherOption) Pusher {
	return newWritePusher(writer, options...)
}

// NewTextWritePusher constructs a new Pusher using a TextMarshaller and newlines.
func NewTextWritePusher(writer io.Writer, textMarshallerOptions ...TextMarshallerOption) Pusher {
	return NewWritePusher(
		writer,
		WritePusherWithMarshaller(NewTextMarshaller(textMarshallerOptions...)),
	)
}

// Unmarshaller unmarshalls a marshalled Entry object. At the end
// of a stream, Unmarshaller will return io.EOF.
type Unmarshaller interface {
	Unmarshal(reader io.Reader, entry *Entry) error
}

// TextMarshaller is a Marshaller used for text.
type TextMarshaller interface {
	Marshaller
}

// TextMarshallerOption is an option for creating Marshallers.
type TextMarshallerOption func(*textMarshaller)

// TextMarshallerDisableTime will suppress the printing of Entry Timestamps.
func TextMarshallerDisableTime() TextMarshallerOption {
	return func(textMarshaller *textMarshaller) {
		textMarshaller.disableTime = true
	}
}

// TextMarshallerDisableLevel will suppress the printing of Entry Levels.
func TextMarshallerDisableLevel() TextMarshallerOption {
	return func(textMarshaller *textMarshaller) {
		textMarshaller.disableLevel = true
	}
}

// TextMarshallerDisableContexts will suppress the printing of Entry contexts.
func TextMarshallerDisableContexts() TextMarshallerOption {
	return func(textMarshaller *textMarshaller) {
		textMarshaller.disableContexts = true
	}
}

// TextMarshallerDisableNewlines disables newlines after each marshalled Entry.
func TextMarshallerDisableNewlines() TextMarshallerOption {
	return func(textMarshaller *textMarshaller) {
		textMarshaller.disableNewlines = true
	}
}

// NewTextMarshaller constructs a new Marshaller that produces human-readable
// marshalled Entry objects. This Marshaller is currently inefficient.
func NewTextMarshaller(options ...TextMarshallerOption) TextMarshaller {
	return newTextMarshaller(options...)
}

// NewMultiPusher constructs a new Pusher that calls all the given Pushers.
func NewMultiPusher(pushers ...Pusher) Pusher {
	return newMultiPusher(pushers)
}
