package protolog_testing

import (
	"bytes"
	"fmt"
	"io"
	"sync/atomic"
	"testing"
	"time"

	"github.com/Sirupsen/logrus"
	"github.com/sr/protolog"
	"go.pedge.io/protolog/glog"
	"go.pedge.io/protolog/logrus"

	"github.com/stretchr/testify/require"
)

func TestRoundtripAndTextMarshaller(t *testing.T) {
	buffer := bytes.NewBuffer(nil)
	fakeTimer := newFakeTimer(0)
	logger := protolog.NewLogger(
		protolog.NewWritePusher(
			buffer,
		),
		protolog.LoggerWithIDAllocator(newFakeIDAllocator()),
		protolog.LoggerWithTimer(fakeTimer),
	).AtLevel(protolog.LevelDebug)
	logger.Debug(
		&Foo{
			StringField: "one",
			Int32Field:  2,
		},
	)
	logger.Info(
		&Baz{
			Bat: &Baz_Bat{
				Ban: &Baz_Bat_Ban{
					StringField: "one",
					Int32Field:  2,
				},
			},
		},
	)
	logger.Info(&Empty{})
	writer := logger.InfoWriter()
	for _, s := range []string{
		"hello",
		"world",
		"writing",
		"strings",
		"is",
		"fun",
	} {
		_, _ = writer.Write([]byte(s))
	}
	writer = logger.Writer()
	_, _ = writer.Write([]byte("none"))
	logger.Infoln("a normal line")
	logger.WithField("someKey", "someValue").Warnln("a warning line")

	puller := protolog.NewReadPuller(
		buffer,
	)
	writeBuffer := bytes.NewBuffer(nil)
	writePusher := protolog.NewTextWritePusher(
		writeBuffer,
		protolog.TextMarshallerDisableTime(),
	)
	for entry, pullErr := puller.Pull(); pullErr != io.EOF; entry, pullErr = puller.Pull() {
		require.NoError(t, pullErr)
		require.NoError(t, writePusher.Push(entry))
	}
	require.Equal(
		t,
		`DEBUG protolog.testing.Foo {"string_field":"one","int32_field":2}
INFO  protolog.testing.Baz {"bat":{"ban":{"string_field":"one","int32_field":2}}}
INFO  protolog.testing.Empty {}
INFO  hello
INFO  world
INFO  writing
INFO  strings
INFO  is
INFO  fun
NONE  none
INFO  a normal line
WARN  a warning line {"someKey":"someValue"}
`,
		writeBuffer.String(),
	)
}

func TestPrintSomeStuff(t *testing.T) {
	testPrintSomeStuff(t, protolog.DefaultLogger)
}

func TestPrintSomeStuffLogrus(t *testing.T) {
	t.Skip()
	protolog.SetLogger(protolog.NewLogger(protolog_logrus.NewPusher(protolog_logrus.PusherOptions{})).AtLevel(protolog.LevelDebug))
	testPrintSomeStuff(t, protolog.GlobalLogger())
}

func TestPrintSomeStuffLogrusForceColors(t *testing.T) {
	//t.Skip()
	protolog.SetLogger(
		protolog.NewLogger(
			protolog_logrus.NewPusher(
				protolog_logrus.PusherOptions{
					Formatter: &logrus.TextFormatter{
						ForceColors: true,
					},
				},
			),
		).AtLevel(protolog.LevelDebug),
	)
	testPrintSomeStuff(t, protolog.GlobalLogger())
}

func TestPrintSomeStuffGLog(t *testing.T) {
	t.Skip()
	require.NoError(t, protolog_glog.LogToStderr())
	protolog.SetLogger(protolog.NewLogger(protolog_glog.NewPusher()).AtLevel(protolog.LevelDebug))
	testPrintSomeStuff(t, protolog.GlobalLogger())
}

func testPrintSomeStuff(t *testing.T, logger protolog.Logger) {
	logger.Debug(
		&Foo{
			StringField: "one",
			Int32Field:  2,
		},
	)
	logger.Info(
		&Baz{
			Bat: &Baz_Bat{
				Ban: &Baz_Bat_Ban{
					StringField: "one",
					Int32Field:  2,
				},
			},
		},
	)
	writer := logger.InfoWriter()
	for _, s := range []string{
		"hello",
		"world",
		"writing",
		"strings",
		"is",
		"fun",
	} {
		_, _ = writer.Write([]byte(s))
	}
	writer = logger.Writer()
	_, _ = writer.Write([]byte("none"))
	logger.Infoln("a normal line")
	logger.WithField("someKey", "someValue").WithField("someOtherKey", 1).Warnln("a warning line")
	logger.WithField("someKey", "someValue").WithField("someOtherKey", 1).Info(
		&Baz{
			Bat: &Baz_Bat{
				Ban: &Baz_Bat_Ban{
					StringField: "one",
					Int32Field:  2,
				},
			},
		},
	)
}

type fakeIDAllocator struct {
	value int32
}

func newFakeIDAllocator() *fakeIDAllocator {
	return &fakeIDAllocator{-1}
}

func (f *fakeIDAllocator) Allocate() string {
	return fmt.Sprintf("%d", atomic.AddInt32(&f.value, 1))
}

type fakeTimer struct {
	unixTimeUsec int64
}

func newFakeTimer(initialUnixTimeUsec int64) *fakeTimer {
	return &fakeTimer{initialUnixTimeUsec}
}

func (f *fakeTimer) Now() time.Time {
	return time.Unix(f.unixTimeUsec/int64(time.Second), f.unixTimeUsec%int64(time.Second)).UTC()
}

func (f *fakeTimer) Add(secondDelta int64, nanosecondDelta int64) {
	atomic.AddInt64(&f.unixTimeUsec, (secondDelta*int64(time.Second))+nanosecondDelta)
}
