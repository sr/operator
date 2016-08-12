package operatortesting

import (
	"bread"

	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type apiServer struct {
	config *PingerConfig
	chat   operator.ChatClient
}

func (s *apiServer) Ping(context context.Context, request *PingRequest) (*PingResponse, error) {
	if err := s.chat.SendRoomNotification(
		&operator.ChatRoomNotification{
			RoomID:        bread.TestingRoom,
			From:          "pinger.Ping",
			Color:         "green",
			MessageFormat: "text",
			Message:       "pong",
		},
	); err != nil {
		return nil, err
	}
	return &PingResponse{
		Output: &operator.Output{
			PlainText: "pong",
		},
	}, nil
}
