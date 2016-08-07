package operator_test

import (
	"bread/ping"
	"net"
	"testing"

	"google.golang.org/grpc"

	"github.com/golang/protobuf/proto"
	"github.com/sr/operator"
)

type fakeLogger struct{}

func (l *fakeLogger) Info(_ proto.Message) {
}

func (l *fakeLogger) Error(_ proto.Message) {
}

func TestMessageDispatcher(t *testing.T) {
	addr := "localhost:0"
	server := grpc.NewServer()
	pingServer, err := breadping.NewAPIServer(&breadping.PingerConfig{})
	if err != nil {
		t.Fatal(err)
	}
	breadping.RegisterPingerServer(server, pingServer)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		t.Fatalf("Failed to listen: %v", err)
	}
	defer listener.Close()
	go server.Serve(listener)
	conn, err := grpc.Dial(addr, grpc.WithInsecure())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	disp, err := operator.NewMessageDispatcher(
		&fakeLogger{},
		conn,
		"!",
		func(conn *grpc.ClientConn, call string, m *operator.Message) (bool, error) {
			return true, nil
		},
	)
	if err != nil {
		t.Fatal(err)
	}
	for _, tt := range []struct {
		text string
		ok   bool
	}{
		{"!ping ping", true},
		{"!ping", false},
		{"!", false},
		{" !ping ping", false},
		{"ping", false},
		{"", false},
	} {
		ok, _ := disp.Dispatch(&operator.Message{Text: tt.text})
		if ok != tt.ok {
			t.Errorf("message `%s` expected ok %#v got %#v", tt.text, tt.ok, ok)
		}
	}
}
