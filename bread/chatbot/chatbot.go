package chatbot

import (
	"errors"
	"strconv"

	"golang.org/x/net/context"
	"google.golang.org/grpc/metadata"

	"git.dev.pardot.com/Pardot/infrastructure/bread"
	"git.dev.pardot.com/Pardot/infrastructure/bread/hipchat"
)

// A MessageHandler handles chat messages.
type MessageHandler func(*Message) error

// A Message is a chat message sent by a User to a Room.
type Message struct {
	Text  string
	HTML  string
	Color string
	Room  *Room
	User  *User
}

// A Room is a chat room.
type Room struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

// A User is a chat user.
type User struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Email       string `json:"email"`
	Deleted     bool   `json:"is_deleted"`
	MentionName string `json:"mention_name"`
}

// LogHandler is a dummy MessageHandler that logs all messages.
func LogHandler(logger bread.Logger) MessageHandler {
	return func(msg *Message) error {
		logger.Printf("received message: %s", msg.Text)
		return nil
	}
}

func SendRoomMessage(ctx context.Context, client *breadhipchat.Client, msg *Message) error {
	if ctx == nil {
		return errors.New("required argument is nil: ctx")
	}
	if client == nil {
		return errors.New("required argument is nil: client")
	}
	if msg == nil {
		return errors.New("required argument is nil: msg")
	}
	var roomID int64
	if md, ok := metadata.FromContext(ctx); ok {
		if val, ok := md[hipchatRoomIDKey]; ok {
			if len(val) == 1 {
				if i, err := strconv.Atoi(val[0]); err == nil {
					roomID = int64(i)
				}
			}
		}
	}
	if roomID == 0 {
		return errors.New("no chat room ID found in request")
	}
	notif := &breadhipchat.RoomNotification{RoomID: roomID}
	if msg.Color != "" {
		notif.MessageOptions = &breadhipchat.MessageOptions{Color: msg.Color}
	}
	if msg.HTML != "" {
		notif.MessageFormat = "html"
		notif.Message = msg.HTML
	} else {
		notif.MessageFormat = "text"
		notif.Message = msg.Text
	}
	return client.SendRoomNotification(ctx, notif)
}

func EmailFromContext(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	if md, ok := metadata.FromContext(ctx); ok {
		if val, ok := md[bread.UserEmailKey]; ok {
			if len(val) == 1 {
				return val[0]
			}
		}
	}
	return ""
}
