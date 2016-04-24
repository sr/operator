package protolog

import "io"

type writePusher struct {
	writer     io.Writer
	marshaller Marshaller
	newline    bool
}

func newWritePusher(writer io.Writer, options ...WritePusherOption) *writePusher {
	writePusher := &writePusher{
		writer,
		DelimitedMarshaller,
		false,
	}
	for _, option := range options {
		option(writePusher)
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
	if _, err := w.writer.Write(data); err != nil {
		return err
	}
	return nil
}
