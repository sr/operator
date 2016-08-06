package bread

import (
	"errors"
	"os"

	"github.com/sr/operator"
	"google.golang.org/grpc"
)

const (
	HipchatHost = "https://hipchat.dev.pardot.com"
	TestingRoom = 882 // BREAD Testing
	PublicRoom  = 42  // Build & Automate
)

var (
	ErrHipchatTokenMissing = errors.New("required environment variable missing: HIPCHAT_TOKEN")
)

type ChatClient interface {
	SendRoomNotification(*ChatRoomNotification) error
}

type ChatRoomNotification struct {
	Color         string `json:"color"`
	From          string `json:"from"`
	Message       string `json:"message"`
	MessageFormat string `json:"message_format"`
	RoomId        int    `json:"-"`
}

func NewOperatorServer(logger operator.Logger) *grpc.Server {
	return grpc.NewServer(
		grpc.UnaryInterceptor(
			operator.NewInterceptor(
				operator.NewInstrumenter(logger),
				newLDAPAuthorizer(),
			),
		),
	)
}

func NewChatClient() (ChatClient, error) {
	token, ok := os.LookupEnv("HIPCHAT_TOKEN")
	if !ok {
		return nil, ErrHipchatTokenMissing
	}
	return newHipchatClient(HipchatHost, token), nil
}
