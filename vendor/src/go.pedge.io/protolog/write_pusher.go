package protolog

import (
	"io"
	"os"
	"sync"

	"github.com/mattn/go-isatty"
)

var (
	newlineBytes = []byte{'\n'}
)

type writePusher struct {
	writer     io.Writer
	marshaller Marshaller
	newline    bool
	lock       *sync.Mutex
}

func newWritePusher(writer io.Writer, options ...WritePusherOption) *writePusher {
	writePusher := &writePusher{
		writer,
		DelimitedMarshaller,
		false,
		&sync.Mutex{},
	}
	for _, option := range options {
		option(writePusher)
	}
	if file, ok := writer.(*os.File); ok {
		if textMarshaller, ok := writePusher.marshaller.(TextMarshaller); ok {
			if isatty.IsTerminal(file.Fd()) {
				writePusher.marshaller = textMarshaller.WithColors()
			}
		}
	}
	return writePusher
}

type flusher interface {
	Flush() error
}

type syncer interface {
	Sync() error
}

func (w *writePusher) Flush() error {
	if syncer, ok := w.writer.(syncer); ok {
		return syncer.Sync()
	} else if flusher, ok := w.writer.(flusher); ok {
		return flusher.Flush()
	}
	return nil
}

func (w *writePusher) Push(entry *Entry) error {
	data, err := w.marshaller.Marshal(entry)
	if err != nil {
		return err
	}
	w.lock.Lock()
	defer w.lock.Unlock()
	if _, err := w.writer.Write(data); err != nil {
		return err
	}
	return nil
}
