/*
Package protolog defines the main protolog functionality.
*/
package protolog // import "go.pedge.io/protolog"

import (
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"sync"
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
	// LevelFatal is the fatal Level.
	LevelFatal Level = 5
	// LevelPanic is the panic Level.
	LevelPanic Level = 6
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
		LevelFatal: "FATAL",
		LevelPanic: "PANIC",
	}
	nameToLevel = map[string]Level{
		"NONE":  LevelNone,
		"DEBUG": LevelDebug,
		"INFO":  LevelInfo,
		"WARN":  LevelWarn,
		"ERROR": LevelError,
		"FATAL": LevelFatal,
		"PANIC": LevelPanic,
	}

	globalLogger            = DefaultLogger
	globalHooks             = make([]GlobalHook, 0)
	globalRedirectStdLogger = false
	globalLock              = &sync.Mutex{}
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

// GlobalHook is a function that handles a change in the global Logger instance.
type GlobalHook func(Logger)

// GlobalLogger returns the global Logger instance.
func GlobalLogger() Logger {
	return globalLogger
}

// SetLogger sets the global Logger instance.
func SetLogger(logger Logger) {
	globalLock.Lock()
	defer globalLock.Unlock()
	globalLogger = logger
	for _, globalHook := range globalHooks {
		globalHook(globalLogger)
	}
}

// SetLevel sets the global Logger to to be at the given Level.
func SetLevel(level Level) {
	globalLock.Lock()
	defer globalLock.Unlock()
	globalLogger = globalLogger.AtLevel(level)
	for _, globalHook := range globalHooks {
		globalHook(globalLogger)
	}
}

// AddGlobalHook adds a GlobalHook that will be called any time SetLogger or SetLevel is called.
// It will also be called when added.
func AddGlobalHook(globalHook GlobalHook) {
	globalLock.Lock()
	defer globalLock.Unlock()
	globalHooks = append(globalHooks, globalHook)
	globalHook(globalLogger)
}

// RedirectStdLogger will redirect logs to golang's standard logger to the global Logger instance.
func RedirectStdLogger() {
	AddGlobalHook(
		func(logger Logger) {
			log.SetFlags(0)
			log.SetOutput(logger.Writer())
			log.SetPrefix("")
		},
	)
}

// Flusher is an object that can be flushed to a persistent store.
type Flusher interface {
	Flush() error
}

// Logger is the main logging interface. All methods are also replicated
// on the package and attached to a global Logger.
type Logger interface {
	Flusher

	AtLevel(level Level) Logger

	WithContext(context proto.Message) Logger
	Debug(event proto.Message)
	Info(event proto.Message)
	Warn(event proto.Message)
	Error(event proto.Message)
	Fatal(event proto.Message)
	Panic(event proto.Message)
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
	Fatalf(format string, args ...interface{})
	Fatalln(args ...interface{})
	Panicf(format string, args ...interface{})
	Panicln(args ...interface{})
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
	data, err := textMarshalEntry(g, false, false, false, true, false)
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

// Puller pulls Entry objects from a persistent store.
type Puller interface {
	Pull() (*Entry, error)
}

// Unmarshaller unmarshalls a marshalled Entry object. At the end
// of a stream, Unmarshaller will return io.EOF.
type Unmarshaller interface {
	Unmarshal(reader io.Reader, entry *Entry) error
}

// ReadPullerOption is an option for a read Puller.
type ReadPullerOption func(*readPuller)

// ReadPullerWithUnmarshaller uses the Unmarshaller for the read Puller.
//
// By default, DelimitedUnmarshaller is used.
func ReadPullerWithUnmarshaller(unmarshaller Unmarshaller) ReadPullerOption {
	return func(readPuller *readPuller) {
		readPuller.unmarshaller = unmarshaller
	}
}

// NewReadPuller constructs a new Puller that reads from the given Reader.
func NewReadPuller(reader io.Reader, options ...ReadPullerOption) Puller {
	return newReadPuller(reader, options...)
}

// TextMarshaller is a Marshaller used for text.
type TextMarshaller interface {
	Marshaller
	WithColors() TextMarshaller
	WithoutColors() TextMarshaller
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

// Flush calls Flush on the global Logger.
func Flush() error {
	return globalLogger.Flush()
}

// AtLevel calls AtLevel on the global Logger.
func AtLevel(level Level) Logger {
	return globalLogger.AtLevel(level)
}

// WithContext calls WithContext on the global Logger.
func WithContext(context proto.Message) Logger {
	return globalLogger.WithContext(context)
}

// Debug calls Debug on the global Logger.
func Debug(Event proto.Message) {
	globalLogger.Debug(Event)
}

// Info calls Info on the global Logger.
func Info(Event proto.Message) {
	globalLogger.Info(Event)
}

// Warn calls Warn on the global Logger.
func Warn(Event proto.Message) {
	globalLogger.Warn(Event)
}

// Error calls Error on the global Logger.
func Error(Event proto.Message) {
	globalLogger.Error(Event)
}

// Fatal calls Fatal on the global Logger.
func Fatal(Event proto.Message) {
	globalLogger.Fatal(Event)
}

// Panic calls Panic on the global Logger.
func Panic(Event proto.Message) {
	globalLogger.Panic(Event)
}

// Print calls Print on the global Logger.
func Print(Event proto.Message) {
	globalLogger.Print(Event)
}

// DebugWriter calls DebugWriter on the global Logger.
func DebugWriter() io.Writer {
	return globalLogger.DebugWriter()
}

// InfoWriter calls InfoWriter on the global Logger.
func InfoWriter() io.Writer {
	return globalLogger.InfoWriter()
}

// WarnWriter calls WarnWriter on the global Logger.
func WarnWriter() io.Writer {
	return globalLogger.WarnWriter()
}

// ErrorWriter calls ErrorWriter on the global Logger.
func ErrorWriter() io.Writer {
	return globalLogger.ErrorWriter()
}

// Writer calls Writer on the global Logger.
func Writer() io.Writer {
	return globalLogger.Writer()
}

// WithField calls WithField on the global Logger.
func WithField(key string, value interface{}) Logger {
	return globalLogger.WithField(key, value)
}

// WithFields calls WithFields on the global Logger.
func WithFields(fields map[string]interface{}) Logger {
	return globalLogger.WithFields(fields)
}

// Debugf calls Debugf on the global Logger.
func Debugf(format string, args ...interface{}) {
	globalLogger.Debugf(format, args...)
}

// Debugln calls Debugln on the global Logger.
func Debugln(args ...interface{}) {
	globalLogger.Debugln(args...)
}

// Infof calls Infof on the global Logger.
func Infof(format string, args ...interface{}) {
	globalLogger.Infof(format, args...)
}

// Infoln calls Infoln on the global Logger.
func Infoln(args ...interface{}) {
	globalLogger.Infoln(args...)
}

// Warnf calls Warnf on the global Logger.
func Warnf(format string, args ...interface{}) {
	globalLogger.Warnf(format, args...)
}

// Warnln calls Warnln on the global Logger.
func Warnln(args ...interface{}) {
	globalLogger.Warnln(args...)
}

// Errorf calls Errorf on the global Logger.
func Errorf(format string, args ...interface{}) {
	globalLogger.Errorf(format, args...)
}

// Errorln calls Errorln on the global Logger.
func Errorln(args ...interface{}) {
	globalLogger.Errorln(args...)
}

// Fatalf calls Fatalf on the global Logger.
func Fatalf(format string, args ...interface{}) {
	globalLogger.Fatalf(format, args...)
}

// Fatalln calls Fatalln on the global Logger.
func Fatalln(args ...interface{}) {
	globalLogger.Fatalln(args...)
}

// Panicf calls Panicf on the global Logger.
func Panicf(format string, args ...interface{}) {
	globalLogger.Panicf(format, args...)
}

// Panicln calls Panicln on the global Logger.
func Panicln(args ...interface{}) {
	globalLogger.Panicln(args...)
}

// Printf calls Printf on the global Logger.
func Printf(format string, args ...interface{}) {
	globalLogger.Printf(format, args...)
}

// Println calls Println on the global Logger.
func Println(args ...interface{}) {
	globalLogger.Println(args...)
}
