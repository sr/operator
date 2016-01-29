package protolog

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"sync/atomic"
	"time"

	"github.com/golang/protobuf/proto"
	"github.com/matttproud/golang_protobuf_extensions/pbutil"
	"github.com/satori/go.uuid"
)

var (
	// go.uuid calls rand.Read, which gets down to a mutex
	// we just need ids to be unique across logging processes
	// so we use a base ID and then add an atomic int
	// it's not great but it's better than blocking on the mutex
	instanceID = uuid.NewV4().String()
)

type idAllocator struct {
	id    string
	value uint64
}

func (i *idAllocator) Allocate() string {
	return fmt.Sprintf("%s-%d", i.id, atomic.AddUint64(&i.value, 1))
}

type timer struct{}

func (t *timer) Now() time.Time {
	return time.Now().UTC()
}

type errorHandler struct{}

func (e *errorHandler) Handle(err error) {
	panic(err.Error())
}

type marshaller struct{}

func (m *marshaller) Marshal(goEntry *GoEntry) ([]byte, error) {
	entry, err := goEntry.ToEntry()
	if err != nil {
		return nil, err
	}
	buffer := bytes.NewBuffer(nil)
	if _, err := pbutil.WriteDelimited(buffer, entry); err != nil {
		return nil, err
	}
	return buffer.Bytes(), nil
}

type unmarshaller struct{}

func (u *unmarshaller) Unmarshal(reader io.Reader, goEntry *GoEntry) error {
	entry := &Entry{}
	if _, err := pbutil.ReadDelimited(reader, entry); err != nil {
		return err
	}
	iGoEntry, err := entry.ToGoEntry()
	if err != nil {
		return err
	}
	*goEntry = *iGoEntry
	return nil
}

type stdlibJSONMarshaller struct{}

func (s *stdlibJSONMarshaller) Marshal(writer io.Writer, message proto.Message) error {
	data, err := json.Marshal(message)
	if err != nil {
		return err
	}
	_, err = writer.Write(data)
	return err
}
