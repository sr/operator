/*
Package protolog defines the main protolog functionality.
*/
package protolog // import "go.pedge.io/protolog"

import (
	"io"
	"io/ioutil"
	"log"
	"os"
	"sync"
	"time"

	"go.pedge.io/proto/time"

	"github.com/golang/protobuf/proto"
)

var (
	// DefaultLevel is the default Level.
	DefaultLevel = Level_LEVEL_INFO
	// DefaultIDAllocator is the default IDAllocator.
	DefaultIDAllocator = &idAllocator{instanceID, 0}
	// DefaultTimer is the default Timer.
	DefaultTimer = &timer{}
	// DefaultErrorHandler is the default ErrorHandler.
	DefaultErrorHandler = &errorHandler{}
	// DefaultMarshaller is the default Marshaller.
	DefaultMarshaller = &marshaller{}
	// DefaultUnmarshaller is the default Unmarshaller.
	DefaultUnmarshaller = &unmarshaller{}
	// DefaultTextMarshaller is the default text Marshaller.
	DefaultTextMarshaller = NewTextMarshaller(MarshallerOptions{})

	// NOTE: the jsoonpb.Marshaler was EPICALLY SLOW in benchmarks
	// When using the stdlib json.Marshal function instead for the text Marshaller,
	// a speedup of 6X was observed!
	//DefaultJSONMarshaller = &jsonpb.Marshaler{}

	// DefaultJSONMarshaller is the default JSONMarshaller.
	DefaultJSONMarshaller = &stdlibJSONMarshaller{}

	// DiscardLogger is a Logger that discards all logs.
	DiscardLogger = NewLogger(NewDefaultTextWritePusher(NewWriterFlusher(ioutil.Discard)), LoggerOptions{})
	// StdlibJSONMarshaller is a JSONMarshaller that uses the stdlib's json.Marshal function.
	StdlibJSONMarshaller = &stdlibJSONMarshaller{}

	defaultMarshallerOptions = MarshallerOptions{}

	globalLogger            = NewLogger(NewDefaultTextWritePusher(NewFileFlusher(os.Stderr)), LoggerOptions{})
	globalHooks             = make([]GlobalHook, 0)
	globalRedirectStdLogger = false
	globalLock              = &sync.Mutex{}
)

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

// WriteFlusher is an io.Writer that can be flushed.
type WriteFlusher interface {
	io.Writer
	Flusher
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

// GoEntry is the go equivalent of an Entry.
type GoEntry struct {
	// ID may not be set depending on LoggerOptions.
	// it is up to the user to determine if ID is required.
	ID       string          `json:"id,omitempty"`
	Level    Level           `json:"level,omitempty"`
	Time     time.Time       `json:"time,omitempty"`
	Contexts []proto.Message `json:"contexts,omitempty"`
	Event    proto.Message   `json:"event,omitempty"`
}

// ToEntry converts the GoEntry to an Entry.
func (g *GoEntry) ToEntry() (*Entry, error) {
	contexts, err := messagesToEntryMessages(g.Contexts)
	if err != nil {
		return nil, err
	}
	event, err := messageToEntryMessage(g.Event)
	if err != nil {
		return nil, err
	}
	return &Entry{
		Id:        g.ID,
		Level:     g.Level,
		Timestamp: prototime.TimeToTimestamp(g.Time),
		Context:   contexts,
		Event:     event,
	}, nil
}

// String defaults a string representation of the GoEntry.
func (g *GoEntry) String() string {
	return g.FullString(defaultMarshallerOptions)
}

// FullString returns a string representation of the GoEntry using the given MarshallerOptions.
func (g *GoEntry) FullString(options MarshallerOptions) string {
	if g == nil {
		return ""
	}
	data, err := textMarshalGoEntry(g, options)
	if err != nil {
		return ""
	}
	return string(data)
}

// Pusher is the interface used to push Entry objects to a persistent store.
type Pusher interface {
	Flusher
	Push(goEntry *GoEntry) error
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

// LoggerOptions defines options for the Logger constructor.
type LoggerOptions struct {
	EnableID     bool
	IDAllocator  IDAllocator
	Timer        Timer
	ErrorHandler ErrorHandler
	Level        Level
}

// NewLogger constructs a new Logger using the given Pusher.
func NewLogger(pusher Pusher, options LoggerOptions) Logger {
	return newLogger(pusher, options)
}

// Marshaller marshals Entry objects to be written.
type Marshaller interface {
	Marshal(goEntry *GoEntry) ([]byte, error)
}

// WritePusherOptions defines options for constructing a new write Pusher.
type WritePusherOptions struct {
	Marshaller Marshaller
	Newline    bool
}

// NewWritePusher constructs a new Pusher that writes to the given WriteFlusher.
func NewWritePusher(writeFlusher WriteFlusher, options WritePusherOptions) Pusher {
	return newWritePusher(writeFlusher, options)
}

// NewDefaultTextWritePusher constructs a new Pusher using the DefaultTextMarshaller and newlines.
func NewDefaultTextWritePusher(writeFlusher WriteFlusher) Pusher {
	return NewWritePusher(
		writeFlusher,
		WritePusherOptions{
			Marshaller: DefaultTextMarshaller,
			Newline:    true,
		},
	)
}

// Puller pulls Entry objects from a persistent store.
type Puller interface {
	Pull() (*GoEntry, error)
}

// Unmarshaller unmarshalls a marshalled Entry object. At the end
// of a stream, Unmarshaller will return io.EOF.
type Unmarshaller interface {
	Unmarshal(reader io.Reader, goEntry *GoEntry) error
}

// ReadPullerOptions defines options for a read Puller.
type ReadPullerOptions struct {
	Unmarshaller Unmarshaller
}

// NewReadPuller constructs a new Puller that reads from the given Reader
// and decodes using the given Unmarshaller.
func NewReadPuller(reader io.Reader, options ReadPullerOptions) Puller {
	return newReadPuller(reader, options)
}

// JSONMarshaller marshals a proto.Message into JSON.
type JSONMarshaller interface {
	Marshal(io.Writer, proto.Message) error
}

// MarshallerOptions provides options for creating Marshallers.
type MarshallerOptions struct {
	// DisableTime will suppress the printing of Entry Timestamps.
	DisableTime bool
	// DisableLevel will suppress the printing of Entry Levels.
	DisableLevel bool
	// DisableContexts will suppress the printing of Entry contexts.
	DisableContexts bool
	// If JSON marshalling is done within the Marshaller, use this JSONMarshaller instead
	JSONMarshaller JSONMarshaller
}

// NewTextMarshaller constructs a new Marshaller that produces human-readable
// marshalled Entry objects. This Marshaller is current inefficient.
func NewTextMarshaller(options MarshallerOptions) Marshaller {
	return newTextMarshaller(options)
}

// NewWriterFlusher wraps an io.Writer into a WriteFlusher.
// Flush() is a no-op on the returned WriteFlusher.
func NewWriterFlusher(writer io.Writer) WriteFlusher {
	return newWriterFlusher(writer)
}

// FileFlusher wraps an *os.File into a Flusher.
// Flush() will call Sync().
type FileFlusher struct {
	*os.File
}

// NewFileFlusher constructs a new FileFlusher for the given *os.File.
func NewFileFlusher(file *os.File) *FileFlusher {
	return &FileFlusher{file}
}

// Flush calls Sync.
func (f *FileFlusher) Flush() error {
	return f.Sync()
}

// NewMultiWriteFlusher constructs a new WriteFlusher that calls all the given WriteFlushers.
func NewMultiWriteFlusher(writeFlushers ...WriteFlusher) WriteFlusher {
	return newMultiWriteFlusher(writeFlushers)
}

// NewMultiPusher constructs a new Pusher that calls all the given Pushers.
func NewMultiPusher(pushers ...Pusher) Pusher {
	return newMultiPusher(pushers)
}

// UnmarshalledContexts returns the context Messages marshalled on an Entry object.
func (m *Entry) UnmarshalledContexts() ([]proto.Message, error) {
	return entryMessagesToMessages(m.Context)
}

// UnmarshalledEvent returns the event Message marshalled on an Entry object.
func (m *Entry) UnmarshalledEvent() (proto.Message, error) {
	return entryMessageToMessage(m.Event)
}

// ToGoEntry converts to Entry to a GoEntry.
func (m *Entry) ToGoEntry() (*GoEntry, error) {
	contexts, err := m.UnmarshalledContexts()
	if err != nil {
		return nil, err
	}
	event, err := m.UnmarshalledEvent()
	if err != nil {
		return nil, err
	}
	return &GoEntry{
		ID:       m.Id,
		Level:    m.Level,
		Time:     prototime.TimestampToTime(m.Timestamp),
		Contexts: contexts,
		Event:    event,
	}, nil
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
