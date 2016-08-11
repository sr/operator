package breadping

import (
	"bread"

	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type apiServer struct {
	config *PingerConfig
	chat   bread.ChatClient
}

func (s *apiServer) Ping(context context.Context, request *PingRequest) (*PingResponse, error) {
	s.chat.SendRoomNotification(
		&bread.ChatRoomNotification{
			RoomID:        bread.TestingRoom,
			From:          "pinger.Ping",
			Color:         "green",
			MessageFormat: "text",
			Message:       "pong",
		},
	)
	return &PingResponse{
		Output: &operator.Output{
			PlainText: "pong",
		},
	}, nil
}
