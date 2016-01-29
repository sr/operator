package protolog_benchmark_marshal

import (
	"testing"
	"time"

	"github.com/golang/protobuf/proto"
	"github.com/sr/protolog"
	"go.pedge.io/protolog/testing"

	"github.com/stretchr/testify/require"
)

func BenchmarkDelimitedMarshaller(b *testing.B) {
	benchmarkMarshaller(b, protolog.DelimitedMarshaller)
}

func BenchmarkDefaultTextMarshaller(b *testing.B) {
	benchmarkMarshaller(b, protolog.NewTextMarshaller())
}

func benchmarkMarshaller(b *testing.B, marshaller protolog.Marshaller) {
	b.StopTimer()
	entry := getBenchEntry()
	_, err := marshaller.Marshal(entry)
	require.NoError(b, err)
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		_, _ = marshaller.Marshal(entry)
	}
}

func getBenchEntry() *protolog.Entry {
	foo := &protolog_testing.Foo{
		StringField: "one",
		Int32Field:  2,
	}
	bar := &protolog_testing.Bar{
		StringField: "one",
		Int32Field:  2,
	}
	baz := &protolog_testing.Baz{
		Bat: &protolog_testing.Baz_Bat{
			Ban: &protolog_testing.Baz_Bat_Ban{
				StringField: "one",
				Int32Field:  2,
			},
		},
	}
	entry := &protolog.Entry{
		ID:    "123",
		Level: protolog.LevelInfo,
		Time:  time.Now().UTC(),
		Contexts: []proto.Message{
			foo,
			bar,
		},
		Event: baz,
	}
	return entry
}
