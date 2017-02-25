package bread

import (
	"errors"
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"time"
	"unicode"

	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"git.dev.pardot.com/Pardot/bread/pb/hal9000"
)

// A chatCommand is a RPC request received via chat.
type chatCommand struct {
	HalMessage *hal9000.Message
	Request    *operator.Request
}

// NewHipchatHandler returns an http.HandlerFunc that receives chat messages via
// webhook requests from HipChat, and dispatches them to either HAL9000 or any
// other gRPC service registered on the server.
func NewHipchatHandler(
	logger Logger,
	decoder operator.Decoder,
	sender operator.Sender,
	conn *grpc.ClientConn,
	invoker operator.InvokerFunc,
	svcInfo map[string]grpc.ServiceInfo,
	hal hal9000.RobotClient,
	timeout time.Duration,
	prefix string,
	pkg string,
) (http.HandlerFunc, error) {
	matcher, err := regexp.Compile(fmt.Sprintf(operator.ReCommandMessage, regexp.QuoteMeta(prefix)))
	if err != nil {
		return nil, err
	}
	return func(w http.ResponseWriter, r *http.Request) {
		// Decode the webhook request into a operator.Message and verify its integrity.
		msg, senderID, err := decoder.Decode(context.TODO(), r)
		if err != nil || msg.Text == "" {
			http.Error(w, fmt.Sprintf("error decoding hipchat request: %s", err), http.StatusBadRequest)
			return
		}

		cmd := &chatCommand{}

		// Check whether the message matches any of the services registered on the gRPC server.
		if req, err := matchMessageToRequest(matcher, pkg, msg, senderID); err != nil {
			logger.Printf(`level=error message="%s"`, err)
		} else {
			if svc, ok := svcInfo[req.Call.Service]; ok {
				for _, m := range svc.Methods {
					if m.Name == req.Call.Method {
						cmd.Request = req
						break
					}
				}
			}
		}

		// Check whether the message matches any of the registered handlers in HAL9000
		// using to hal9000.Match(Message) gRPC method.
		halMessage := &hal9000.Message{Text: msg.Text, User: &hal9000.User{}}
		if msg.Source != nil && msg.Source.User != nil && msg.Source.Room != nil {
			halMessage.User.Email = msg.Source.User.Email
			halMessage.User.Name = msg.Source.User.Login
			halMessage.Room = msg.Source.Room.Name
		}
		if _, err := hal.IsMatch(context.TODO(), halMessage); err != nil {
			logger.Printf("error determine whether message should be dispatched to HAL9000: %s", err)
		} else {
			cmd.HalMessage = halMessage
		}

		if cmd.Request != nil {
			logger.Printf(`level=debug type=grpc service="%s" method="%s"`, cmd.Request.Call.Service, cmd.Request.Call.Method)
		}
		if cmd.HalMessage != nil {
			logger.Printf(`level=debug type=hal message="%s"`, cmd.HalMessage.Text)
		}

		// Dispatch the RPC request in the background.
		go func() {
			handle(context.Background(), timeout, sender, conn, hal, invoker, pkg, cmd)
		}()

		w.WriteHeader(201)
	}, nil
}

// handle dispatches a request to either the HAL9000 service or any other
// service using InvokerFunc (typically generated code) and a gRPC connection.
//
// TODO(sr) currently requests can only be dispatched to services within the
// the same protobuf package (see pkg argument). It should be possible to
// dispatch requests accross package boundaries.
func handle(ctx context.Context, timeout time.Duration, sender operator.Sender, conn *grpc.ClientConn, hal hal9000.RobotClient, invoker operator.InvokerFunc, pkg string, cmd *chatCommand) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	errC := make(chan error, 1)
	go func() {
		if cmd.Request != nil {
			errC <- invoker(ctx, conn, cmd.Request, pkg)
		} else if cmd.HalMessage != nil {
			_, err := hal.Dispatch(ctx, cmd.HalMessage)
			errC <- err
		} else {
			errC <- errors.New("unhandled request")
		}
	}()
	var err error
	select {
	case <-ctx.Done():
		err = fmt.Errorf("RPC request failed to complete in time")
	case err = <-errC:
	}
	// Send RPC and timeout errors to the chat room were the request originated from.
	if err != nil && cmd.Request != nil && sender != nil && !strings.Contains(err.Error(), "no such service:") {
		_ = sender.Send(ctx, cmd.Request.GetSource(), cmd.Request.SenderId, &operator.Message{
			Text:    grpc.ErrorDesc(err),
			HTML:    fmt.Sprintf("Request failed: <code>%s</code>", grpc.ErrorDesc(err)),
			Options: &operatorhipchat.MessageOptions{Color: "red"},
		})
	}
}

// matchMessageToRequest attempts to find a "!service method args=val" command
// in the decoded chat message and returns an operator.Request value that can
// then be passed to an InvokerFunc function, or nil and an error if no command
// is found in the message.
func matchMessageToRequest(matcher *regexp.Regexp, pkg string, msg *operator.Message, senderID string) (*operator.Request, error) {
	matches := matcher.FindStringSubmatch(msg.Text)
	if matches == nil {
		return nil, fmt.Errorf("no command found in message: %s", msg.Text)
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
	return &operator.Request{
		Call: &operator.Call{
			Service: fmt.Sprintf("%s.%s", pkg, operator.Camelize(matches[1], "-")),
			Method:  operator.Camelize(matches[2], "-"),
			Args:    args,
		},
		SenderId: senderID,
		Source:   msg.Source,
	}, nil
}
