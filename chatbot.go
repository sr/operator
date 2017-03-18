package bread

import (
	"errors"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"
	"unicode"

	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

// hipchatRoomIDKey is the grpc metadata.MD key used for injecting the source
// of chat commands into gRPC requests so that the server can send notifications
// to the right place.
const hipchatRoomIDKey = "hipchat_room_id"

// commandMatcher is used to find commands in chat messages, e.g. !deploy trigger target=events
var commandMatcher = regexp.MustCompile(`\A!(?P<service>[\w|-]+)\s+(?P<method>[\w|\-]+)(?:\s+(?P<options>.*))?\z`)

// A ChatMessageHandler handles chat messages.
type ChatMessageHandler func(*ChatMessage) error

// ChatCommand is a RPC request sent as a chat message
type ChatCommand struct {
	Package   string
	Service   string
	Method    string
	Args      map[string]string
	RoomID    int
	UserEmail string
}

// A ChatMessage is a chat message sent by a User to a Room.
type ChatMessage struct {
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

func LogHandler(logger Logger) ChatMessageHandler {
	return func(msg *ChatMessage) error {
		logger.Printf("received message: %s", msg.Text)
		return nil
	}
}

func ChatCommandHandler(defaultPackage string, c chan<- *ChatCommand) ChatMessageHandler {
	return func(msg *ChatMessage) error {
		if msg == nil || msg.Text == "" {
			return nil
		}
		if msg.Room == nil {
			return errors.New("chat message does not have a room")
		}
		if msg.User == nil || msg.User.Email == "" {
			return errors.New("chat message does not have a user")
		}
		cmd := findChatCommand(msg.Text)
		if cmd == nil {
			return fmt.Errorf("no command found in message: %s", msg.Text)
		}
		cmd.RoomID = msg.Room.ID
		cmd.UserEmail = msg.User.Email
		cmd.Package = defaultPackage
		c <- cmd
		return nil
	}
}

type ChatCommandInvoker func(context.Context, *grpc.ClientConn, *ChatCommand) error

func HandleChatRPCCommand(client operatorhipchat.Client, invoker ChatCommandInvoker, timeout time.Duration, conn *grpc.ClientConn, cmd *ChatCommand) error {
	if client == nil {
		return errors.New("required argument is nil: client")
	}
	if invoker == nil {
		return errors.New("required argument is nil: invoker")
	}
	if timeout == time.Duration(0) {
		return errors.New("required argument is nil: timeout")
	}
	if conn == nil {
		return errors.New("required argument is nil: conn")
	}
	if cmd == nil {
		return errors.New("required argument is nil: cmd")
	}
	if cmd.Package == "" {
		return errors.New("required command field is nil: Package")
	}
	if cmd.Service == "" {
		return errors.New("required command field is nil: Service")
	}
	if cmd.Method == "" {
		return errors.New("required command field is nil: Method")
	}
	if cmd.RoomID == 0 {
		return errors.New("required command field is nil: RoomID")
	}

	ctx, cancel := context.WithTimeout(
		metadata.NewContext(
			context.TODO(),
			metadata.Pairs(
				hipchatRoomIDKey,
				strconv.Itoa(cmd.RoomID),
				userEmailKey,
				cmd.UserEmail,
			),
		),
		timeout,
	)
	defer cancel()

	errC := make(chan error, 1)
	go func() {
		errC <- invoker(ctx, conn, cmd)
	}()

	var err error
	select {
	case <-ctx.Done():
		err = fmt.Errorf("RPC request failed to complete in time")
	case err = <-errC:
	}

	if err != nil && !strings.Contains(err.Error(), "no such service:") {
		_ = client.SendRoomNotification(
			context.TODO(),
			&operatorhipchat.RoomNotification{
				RoomID:         int64(cmd.RoomID),
				MessageFormat:  "html",
				Message:        fmt.Sprintf("Request failed: <code>%s</code>", grpc.ErrorDesc(err)),
				MessageOptions: &operatorhipchat.MessageOptions{Color: "red"},
			},
		)
	}
	return err
}

func findChatCommand(msg string) *ChatCommand {
	matches := commandMatcher.FindStringSubmatch(msg)
	if matches == nil {
		return nil
	}
	args := make(map[string]string)
	lastQuote := rune(0)
	words := strings.FieldsFunc(matches[3], func(c rune) bool {
		switch {
		case c == lastQuote:
			lastQuote = rune(0)
			return false
		case lastQuote != rune(0):
			return false
		case unicode.In(c, unicode.Quotation_Mark):
			lastQuote = c
			return false
		default:
			return unicode.IsSpace(c)
		}
	})
	for _, arg := range words {
		parts := strings.Split(arg, "=")
		if len(parts) != 2 {
			continue
		}
		args[parts[0]] = strings.TrimFunc(parts[1], func(c rune) bool {
			return unicode.In(c, unicode.Quotation_Mark)
		})
	}
	return &ChatCommand{
		Service: camelize(matches[1], "-"),
		Method:  camelize(matches[2], "-"),
		Args:    args,
	}
}

func camelize(s string, sep string) string {
	var result string
	words := strings.Split(s, sep)
	for _, word := range words {
		if len(word) > 0 {
			w := []rune(word)
			w[0] = unicode.ToUpper(w[0])
			result += string(w)
		}
	}
	return result
}
