package chatbot

import "git.dev.pardot.com/Pardot/infrastructure/bread"

// A MessageHandler handles chat messages.
type MessageHandler func(*Message) error

// A Message is a chat message sent by a User to a Room.
type Message struct {
	Text string
	Room *Room
	User *User
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
