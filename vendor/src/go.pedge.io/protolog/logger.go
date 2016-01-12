package protolog

import (
	"fmt"
	"io"
	"os"

	"github.com/golang/protobuf/proto"
)

type logger struct {
	pusher       Pusher
	enableID     bool
	idAllocator  IDAllocator
	timer        Timer
	errorHandler ErrorHandler
	level        Level
	contexts     []proto.Message
	fields       map[string]string
}

func newLogger(pusher Pusher, options ...LoggerOption) *logger {
	logger := &logger{
		pusher,
		false,
		DefaultIDAllocator,
		DefaultTimer,
		DefaultErrorHandler,
		DefaultLevel,
		make([]proto.Message, 0),
		make(map[string]string, 0),
	}
	for _, option := range options {
		option(logger)
	}
	return logger
}

func (l *logger) Flush() error {
	return l.pusher.Flush()
}

func (l *logger) AtLevel(level Level) Logger {
	return &logger{
		l.pusher,
		l.enableID,
		l.idAllocator,
		l.timer,
		l.errorHandler,
		level,
		l.contexts,
		l.fields,
	}
}

func (l *logger) WithContext(context proto.Message) Logger {
	return &logger{
		l.pusher,
		l.enableID,
		l.idAllocator,
		l.timer,
		l.errorHandler,
		l.level,
		append(l.contexts, context),
		l.fields,
	}
}

func (l *logger) Debug(event proto.Message) {
	l.print(LevelDebug, event, "", nil)
}

func (l *logger) Info(event proto.Message) {
	l.print(LevelInfo, event, "", nil)
}

func (l *logger) Warn(event proto.Message) {
	l.print(LevelWarn, event, "", nil)
}

func (l *logger) Error(event proto.Message) {
	l.print(LevelError, event, "", nil)
}

func (l *logger) Fatal(event proto.Message) {
	l.print(LevelFatal, event, "", nil)
	os.Exit(1)
}

func (l *logger) Panic(event proto.Message) {
	l.print(LevelPanic, event, "", nil)
	panic(fmt.Sprintf("%+v", event))
}

func (l *logger) Print(event proto.Message) {
	l.print(LevelNone, event, "", nil)
}

func (l *logger) DebugWriter() io.Writer {
	return l.printWriter(LevelDebug)
}

func (l *logger) InfoWriter() io.Writer {
	return l.printWriter(LevelInfo)
}

func (l *logger) WarnWriter() io.Writer {
	return l.printWriter(LevelWarn)
}

func (l *logger) ErrorWriter() io.Writer {
	return l.printWriter(LevelError)
}

func (l *logger) Writer() io.Writer {
	return l.printWriter(LevelNone)
}

func (l *logger) WithField(key string, value interface{}) Logger {
	contextFields := make(map[string]string, len(l.fields)+1)
	contextFields[key] = fmt.Sprintf("%v", value)
	for key, value := range l.fields {
		contextFields[key] = value
	}
	return &logger{
		l.pusher,
		l.enableID,
		l.idAllocator,
		l.timer,
		l.errorHandler,
		l.level,
		l.contexts,
		contextFields,
	}
}

func (l *logger) WithFields(fields map[string]interface{}) Logger {
	contextFields := make(map[string]string, len(l.fields)+len(fields))
	for key, value := range fields {
		contextFields[key] = fmt.Sprintf("%v", value)
	}
	for key, value := range l.fields {
		contextFields[key] = value
	}
	return &logger{
		l.pusher,
		l.enableID,
		l.idAllocator,
		l.timer,
		l.errorHandler,
		l.level,
		l.contexts,
		contextFields,
	}
}

func (l *logger) Debugf(format string, args ...interface{}) {
	l.print(LevelDebug, nil, fmt.Sprintf(format, args...), nil)
}

func (l *logger) Debugln(args ...interface{}) {
	l.print(LevelDebug, nil, fmt.Sprint(args...), nil)
}

func (l *logger) Infof(format string, args ...interface{}) {
	l.print(LevelInfo, nil, fmt.Sprintf(format, args...), nil)
}

func (l *logger) Infoln(args ...interface{}) {
	l.print(LevelInfo, nil, fmt.Sprint(args...), nil)
}

func (l *logger) Warnf(format string, args ...interface{}) {
	l.print(LevelWarn, nil, fmt.Sprintf(format, args...), nil)
}

func (l *logger) Warnln(args ...interface{}) {
	l.print(LevelWarn, nil, fmt.Sprint(args...), nil)
}

func (l *logger) Errorf(format string, args ...interface{}) {
	l.print(LevelError, nil, fmt.Sprintf(format, args...), nil)
}

func (l *logger) Errorln(args ...interface{}) {
	l.print(LevelError, nil, fmt.Sprint(args...), nil)
}

func (l *logger) Fatalf(format string, args ...interface{}) {
	l.print(LevelFatal, nil, fmt.Sprintf(format, args...), nil)
	os.Exit(1)
}

func (l *logger) Fatalln(args ...interface{}) {
	l.print(LevelFatal, nil, fmt.Sprint(args...), nil)
	os.Exit(1)
}

func (l *logger) Panicf(format string, args ...interface{}) {
	l.print(LevelPanic, nil, fmt.Sprintf(format, args...), nil)
	panic(fmt.Sprintf(format, args...))
}

func (l *logger) Panicln(args ...interface{}) {
	l.print(LevelPanic, nil, fmt.Sprint(args...), nil)
	panic(fmt.Sprint(args...))
}

func (l *logger) Printf(format string, args ...interface{}) {
	l.print(LevelNone, nil, fmt.Sprintf(format, args...), nil)
}

func (l *logger) Println(args ...interface{}) {
	l.print(LevelNone, nil, fmt.Sprint(args...), nil)
}

func (l *logger) print(level Level, event proto.Message, message string, writerOutput []byte) {
	if err := l.printWithError(level, event, message, writerOutput); err != nil {
		l.errorHandler.Handle(err)
	}
}

func (l *logger) printWriter(level Level) io.Writer {
	// TODO(pedge): think more about this
	//if !l.isLoggedLevel(level) {
	//return ioutil.Discard
	//}
	return newLogWriter(l, level)
}

func (l *logger) printWithError(level Level, event proto.Message, message string, writerOutput []byte) error {
	if !l.isLoggedLevel(level) {
		return nil
	}
	entry := &Entry{
		Level: level,
		Time:  l.timer.Now(),
		// TODO(pedge): should copy this but has performance hit
		Contexts: l.contexts,
		// TODO(pedge): should copy this but has performance hit
		Fields:       l.fields,
		Event:        event,
		Message:      message,
		WriterOutput: writerOutput,
	}
	if l.enableID {
		entry.ID = l.idAllocator.Allocate()
	}
	return l.pusher.Push(entry)
}

func (l *logger) isLoggedLevel(level Level) bool {
	return level >= l.level || level == LevelNone
}

type logWriter struct {
	logger *logger
	level  Level
}

func newLogWriter(logger *logger, level Level) *logWriter {
	return &logWriter{logger, level}
}

func (w *logWriter) Write(p []byte) (int, error) {
	if err := w.logger.printWithError(w.level, nil, "", p); err != nil {
		return 0, err
	}
	return len(p), nil
}
