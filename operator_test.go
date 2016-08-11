package operator_test

import (
	"bread/ping"
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"

	"google.golang.org/grpc"

	"github.com/golang/protobuf/proto"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
)

var logger = &fakeLogger{}

type fakeLogger struct{}

type fakeAuthorizer struct{}

func (l *fakeLogger) Info(_ proto.Message) {
}

func (l *fakeLogger) Error(_ proto.Message) {
}

func (a *fakeAuthorizer) Authorize(_ *operator.Request) error {
	return nil
}

func TestHandler(t *testing.T) {
	addr := "localhost:0"
	server := grpc.NewServer()
	defer server.Stop()
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
	h, err := operator.NewHandler(
		logger,
		operator.NewInstrumenter(logger),
		&fakeAuthorizer{},
		operatorhipchat.NewRequestDecoder(),
		"!",
		conn,
		func(conn *grpc.ClientConn, req *operator.Request) (bool, error) {
			return true, nil
		},
	)
	if err != nil {
		t.Fatal(err)
	}
	ts := httptest.NewServer(h)
	for _, tt := range []struct {
		text   string
		status int
	}{
		{"!ping ping", 200},
		{"!ping", 404},
		{"!", 404},
		{" !ping ping", 404},
		{"ping", 404},
		{"", 404},
	} {
		webhook := &operatorhipchat.Payload{
			Event: "room_message",
			Item: &operatorhipchat.Item{
				Message: &operatorhipchat.Message{
					Message: tt.text,
					From: &operatorhipchat.User{
						ID:          1,
						MentionName: "breadsignal",
						Name:        "Breadman",
					},
				},
				Room: &operatorhipchat.Room{
					ID:   1,
					Name: "BREAD",
				},
			},
		}
		data, err := json.Marshal(webhook)
		if err != nil {
			t.Fatal(err)
		}
		resp, err := http.Post(ts.URL, "application/json", bytes.NewReader(data))
		if err != nil {
			t.Fatal(err)
		}
		if resp.StatusCode != tt.status {
			t.Errorf("message `%s` expected status code %d, got %#v", tt.text, tt.status, resp.StatusCode)
		}
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			t.Fatal(err)
		}
		defer resp.Body.Close()
		fmt.Printf("%s", body)
	}
}
