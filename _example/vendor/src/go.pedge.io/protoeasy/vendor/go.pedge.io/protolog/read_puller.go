package protolog

import "io"

type readPuller struct {
	reader       io.Reader
	unmarshaller Unmarshaller
}

func newReadPuller(reader io.Reader, options ReadPullerOptions) *readPuller {
	readPuller := &readPuller{
		reader,
		options.Unmarshaller,
	}
	if readPuller.unmarshaller == nil {
		readPuller.unmarshaller = DefaultUnmarshaller
	}
	return readPuller
}

func (r *readPuller) Pull() (*GoEntry, error) {
	goEntry := &GoEntry{}
	if err := r.unmarshaller.Unmarshal(r.reader, goEntry); err != nil {
		return nil, err
	}
	return goEntry, nil
}
