package chatbot_test

import (
	"fmt"
	"net"
	"reflect"
	"strings"
	"testing"
	"time"

	"github.com/golang/protobuf/ptypes/empty"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"

	"git.dev.pardot.com/Pardot/infrastructure/bread"
	"git.dev.pardot.com/Pardot/infrastructure/bread/chatbot"
	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb"
)

func TestGRPCMessageHandler(t *testing.T) {
	commands := make(chan *chatbot.Command, 1)
	handler := chatbot.GRPCMessageHandler("package", commands)

	for _, tc := range []struct {
		message string
		want    *chatbot.Command
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
			&chatbot.Command{
				Call: &bread.RPC{
					Package: "package",
					Service: "Ping",
					Method:  "Ping",
				},
				Args:      map[string]string{},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
		{
			"!ping ping-pong",
			&chatbot.Command{
				Call: &bread.RPC{
					Package: "package",
					Service: "Ping",
					Method:  "PingPong",
				},
				Args:      map[string]string{},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
		{
			"!ping ping",
			&chatbot.Command{
				Call: &bread.RPC{
					Package: "package",
					Service: "Ping",
					Method:  "Ping",
				},
				Args:      map[string]string{},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
		{
			"!deploy trigger app=chatbot",
			&chatbot.Command{
				Call: &bread.RPC{
					Package: "package",
					Service: "Deploy",
					Method:  "Trigger",
				},
				Args: map[string]string{
					"app": "chatbot",
				},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
		{
			"!deploy trigger app=chatbot env=\"boomtown\"",
			&chatbot.Command{
				Call: &bread.RPC{
					Package: "package",
					Service: "Deploy",
					Method:  "Trigger",
				},
				Args: map[string]string{
					"app": "chatbot",
					"env": "boomtown",
				},
				RoomID:    42,
				UserEmail: "user@salesforce.com",
			},
		},
	} {
		msg := &chatbot.Message{
			Text: tc.message,
			Room: &chatbot.Room{
				ID: 42,
			},
			User: &chatbot.User{
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

type pingServer struct {
	lastRoomID string
}

func (s *pingServer) Ping(ctx context.Context, req *breadpb.PingRequest) (*empty.Empty, error) {
	if md, ok := metadata.FromContext(ctx); ok {
		if _, ok := md["chat_room_id"]; ok {
			s.lastRoomID = md["chat_room_id"][0]
		}
	}
	return &empty.Empty{}, nil
}

var invoker chatbot.CommandInvoker = func(ctx context.Context, conn *grpc.ClientConn, cmd *chatbot.Command) error {
	if cmd.Call.Package == "bread" {
		if cmd.Call.Service == "bread" {
			if cmd.Call.Method == "ping" {
				client := breadpb.NewPingerClient(conn)
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
	breadpb.RegisterPingerServer(server, ping)
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
	cmd := &chatbot.Command{Call: &bread.RPC{Package: "bread", Service: "bread", Method: "ping"}, RoomID: 42}
	if err := chatbot.HandleCommand(func(context.Context, *chatbot.Message) error { return nil }, invoker, 1*time.Second, conn, cmd); err != nil {
		t.Fatal(err)
	}
	if ping.lastRoomID != "42" {
		t.Errorf("want room ID %d, got %s", 42, ping.lastRoomID)
	}
}
