package breadapi

import (
	"fmt"

	"github.com/golang/protobuf/ptypes/empty"
	"golang.org/x/net/context"

	"git.dev.pardot.com/Pardot/infrastructure/bread/chatbot"
	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb"
)

type PingerServer struct {
	chatbot.Messenger
}

func (s *PingerServer) Ping(ctx context.Context, req *breadpb.PingRequest) (*empty.Empty, error) {
	email := chatbot.EmailFromContext(ctx)
	return &empty.Empty{}, chatbot.SendRoomMessage(ctx, s.Messenger, &chatbot.Message{
		HTML: fmt.Sprintf(`PONG <a href="mailto:%s">%s</a>`, email, email),
	})
}
