package breadapi

import (
	"fmt"

	"github.com/golang/protobuf/ptypes/empty"
	"golang.org/x/net/context"

	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb"
)

type PingerServer struct {
	Messenger
}

func (s *PingerServer) Ping(ctx context.Context, req *breadpb.PingRequest) (*empty.Empty, error) {
	email := emailFromContext(ctx)
	return &empty.Empty{}, SendRoomMessage(ctx, s.Messenger, &ChatMessage{
		HTML: fmt.Sprintf(`PONG <a href="mailto:%s">%s</a>`, email, email),
	})
}
