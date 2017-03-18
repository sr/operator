package bread_test

import (
	"fmt"
	"net"
	"reflect"
	"strings"
	"testing"
	"time"

	"golang.org/x/net/context"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"

	"git.dev.pardot.com/Pardot/bread"
	"git.dev.pardot.com/Pardot/bread/pb"
)

func TestChatCommandHandler(t *testing.T) {
	commands := make(chan *bread.ChatCommand, 1)
	handler := bread.ChatCommandHandler("package", commands)

	for _, tc := range []struct {
		message string
		want    *bread.ChatCommand
	}{
		{
			"hello world",
			nil,
		},
		{
			"!ping",
			nil,
		},
		{
			"!ping ping",
			&bread.ChatCommand{
				Package:   "package",
				Service:   "Ping",
				Method:    "Ping",
				Args:      map[string]string{},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
		{
			"!ping ping-pong",
			&bread.ChatCommand{
				Package:   "package",
				Service:   "Ping",
				Method:    "PingPong",
				Args:      map[string]string{},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
		{
			"!ping ping",
			&bread.ChatCommand{
				Package:   "package",
				Service:   "Ping",
				Method:    "Ping",
				Args:      map[string]string{},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
		{
			"!deploy trigger app=chatbot",
			&bread.ChatCommand{
				Package: "package",
				Service: "Deploy",
				Method:  "Trigger",
				Args: map[string]string{
					"app": "chatbot",
				},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
		{
			"!deploy trigger app=chatbot env=\"boomtown\"",
			&bread.ChatCommand{
				Package: "package",
				Service: "Deploy",
				Method:  "Trigger",
				Args: map[string]string{
					"app": "chatbot",
					"env": "boomtown",
				},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
	} {
		msg := &bread.ChatMessage{
			Text: tc.message,
			Room: &bread.Room{
				ID: 42,
			},
			User: &bread.User{
				Email: "user@salesforce.com",
			},
		}
		err := handler(msg)
		if err != nil && tc.want != nil && !strings.Contains(err.Error(), "no command found") {
			t.Fatalf("message `%s` error: %s", tc.message, err)
		}
		select {
		case c := <-commands:
			if !reflect.DeepEqual(c, tc.want) {
				t.Errorf("message `%s` want command %#v, got %#v", tc.message, tc.want, c)
			}
		default:
			if tc.want != nil {
				t.Errorf("message `%s` want command %+v, got nil", tc.message, tc.want)
			}
		}
	}
}

type fakeHipchatClient struct{}

func (c *fakeHipchatClient) GetUser(_ context.Context, id int) (*operatorhipchat.User, error) {
	return &operatorhipchat.User{
		ID:    id,
		Email: "jane@salesforce.com",
	}, nil
}

func (c *fakeHipchatClient) SendRoomNotification(_ context.Context, _ *operatorhipchat.RoomNotification) error {
	return nil
}

type pingServer struct {
	lastRoomID string
}

func (s *pingServer) Ping(ctx context.Context, req *breadpb.PingRequest) (*operator.Response, error) {
	if md, ok := metadata.FromContext(ctx); ok {
		if _, ok := md["hipchat_room_id"]; ok {
			s.lastRoomID = md["hipchat_room_id"][0]
		}
	}
	return &operator.Response{}, nil
}

func (s *pingServer) SlowLoris(ctx context.Context, req *breadpb.SlowLorisRequest) (*operator.Response, error) {
	panic("not implemented")
}

var invoker bread.ChatCommandInvoker = func(ctx context.Context, conn *grpc.ClientConn, cmd *bread.ChatCommand) error {
	if cmd.Package == "bread" {
		if cmd.Service == "bread" {
			if cmd.Method == "ping" {
				client := breadpb.NewPingClient(conn)
				_, err := client.Ping(ctx, &breadpb.PingRequest{})
				return err
			}
		}
	}
	return fmt.Errorf("unhandleable command: %+v", cmd)
}

func TestHandleChatCommand(t *testing.T) {
	server := grpc.NewServer()
	defer server.GracefulStop()
	ping := &pingServer{}
	breadpb.RegisterPingServer(server, ping)
	listener, err := net.Listen("tcp", "localhost:0")
	if err != nil {
		t.Fatalf("failed to listen: %v", err)
	}
	defer listener.Close()
	go server.Serve(listener)
	conn, err := grpc.Dial(
		listener.Addr().String(),
		grpc.WithInsecure(),
		grpc.WithBlock(),
	)
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	if err := bread.HandleChatRPCCommand(&fakeHipchatClient{}, invoker, 1*time.Second, conn, &bread.ChatCommand{Package: "bread", Service: "bread", Method: "ping", RoomID: 42}); err != nil {
		t.Fatal(err)
	}
	if ping.lastRoomID != "42" {
		t.Errorf("want room ID %d, got %s", 42, ping.lastRoomID)
	}
}
