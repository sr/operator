package chatbot

import (
	"errors"
	"strconv"

	"golang.org/x/net/context"
	"google.golang.org/grpc/metadata"

	"git.dev.pardot.com/Pardot/infrastructure/bread"
)

// A MessageHandler handles chat messages.
type MessageHandler func(*Message) error

// A Messenger sends messages to a chat room.
type Messenger func(context.Context, *Message) error

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

func SendRoomMessage(ctx context.Context, messenger Messenger, msg *Message) error {
	if ctx == nil {
		return errors.New("required argument is nil: ctx")
	}
	if messenger == nil {
		return errors.New("required argument is nil: messenger")
	}
	if msg == nil {
		return errors.New("required argument is nil: msg")
	}
	msg.Room = &Room{}
	if md, ok := metadata.FromContext(ctx); ok {
		if val, ok := md[chatRoomIDKey]; ok {
			if len(val) == 1 {
				if i, err := strconv.Atoi(val[0]); err == nil {
					msg.Room.ID = i
				}
			}
		}
	}
	if msg.Room.ID == 0 {
		return errors.New("no chat room ID found in request")
	}
	return messenger(ctx, msg)
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
