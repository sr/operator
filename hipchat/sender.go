package operatorhipchat

import (
	"errors"

	"github.com/sr/operator"
	"golang.org/x/net/context"
)

type sender struct {
	store    ClientCredentialsStore
	hostname string
}

func (s *sender) Send(ctx context.Context, src *operator.Source, rep string, msg *operator.Message) error {
	if src.Type != operator.SourceType_HUBOT {
		return nil
	}
	if rep == "" {
		return errors.New("unable to reply without an OAuth ID")
	}
	config, err := s.store.GetByOAuthID(rep)
	if err != nil {
		return err
	}
	client, err := config.Client(ctx)
	if err != nil {
		return err
	}
	if src.Room == nil || src.Room.Id == 0 {
		return errors.New("unable to reply to request without a room ID")
	}
	notif := &RoomNotification{RoomID: src.Room.Id}
	if msg.HTML != "" {
		notif.MessageFormat = "html"
		notif.Message = msg.HTML
	} else {
		notif.MessageFormat = "text"
		notif.Message = msg.Text
	}
	if v, ok := msg.Options.(*MessageOptions); ok {
		notif.MessageOptions = v
	}
	return client.SendRoomNotification(ctx, notif)
}
