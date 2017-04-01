package chatbot

import (
	"golang.org/x/net/context"

	"git.dev.pardot.com/Pardot/infrastructure/bread"
	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb/hal9000"
)

func HAL9000Handler(logger bread.Logger, hal hal9000.RobotClient) MessageHandler {
	return func(msg *Message) error {
		halMessage := &hal9000.Message{Text: msg.Text, User: &hal9000.User{}}
		if msg.User != nil && msg.Room != nil {
			halMessage.User.Name = msg.User.Name
			halMessage.User.Email = msg.User.Email
			halMessage.Room = msg.Room.Name
		}
		resp, err := hal.IsMatch(context.TODO(), halMessage)
		if err != nil {
			logger.Printf("hal9000 error: %s", err)
			return nil
		}
		if !resp.Match {
			logger.Printf("hal9000 not a match: %+v", msg)
			return nil
		}
		if _, err := hal.Dispatch(context.Background(), halMessage); err != nil {
			logger.Printf("hal9000 dispatch error: %s", err)
		}
		return nil
	}
}
