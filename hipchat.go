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

type hipchat struct {
	ctx     context.Context
	logger  Logger
	decoder operator.Decoder
	sender  operator.Sender
	invoker operator.InvokerFunc
	conn    *grpc.ClientConn
	svcInfo map[string]grpc.ServiceInfo
	hal9000 hal9000.RobotClient
	timeout time.Duration
	re      *regexp.Regexp
	pkg     string
}

func (h *hipchat) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	msg, senderID, err := h.decoder.Decode(h.ctx, r)
	if err != nil || msg.Text == "" {
		http.Error(w, fmt.Sprintf("error decoding the request: %s", err), http.StatusBadRequest)
		return
	}
	var breadMatch, halMatch bool
	halMsg := &hal9000.Message{Text: msg.Text, User: &hal9000.User{}}
	if msg.Source != nil && msg.Source.User != nil && msg.Source.Room != nil {
		halMsg.User.Email = msg.Source.User.Email
		halMsg.User.Name = msg.Source.User.Login
		halMsg.Room = msg.Source.Room.Name
	}
	req := h.getRequest(msg, senderID)
	if req != nil {
		if svc, ok := h.svcInfo[req.Call.Service]; ok {
			for _, m := range svc.Methods {
				if m.Name == req.Call.Method {
					breadMatch = true
					break
				}
			}
		}
	}
	if r, err := h.hal9000.IsMatch(h.ctx, halMsg); err != nil {
		fmt.Printf("DEBUG: hal9000 service error: %s\n", err)
	} else if r != nil && r.Match {
		halMatch = true
	}
	if breadMatch && halMatch {
		fmt.Println("WARN: both HAL9000 and Operator match. HAL9000 will be ignored")
	}
	if !breadMatch && !halMatch {
		http.Error(w, fmt.Sprintf("message did not match any service: %s", err), http.StatusNotFound)
		return
	}
	go func(bread bool, hal bool, req *operator.Request, msg *operator.Message, halMsg *hal9000.Message) {
		ctx, cancel := context.WithTimeout(h.ctx, h.timeout)
		defer cancel()
		errC := make(chan error, 1)
		go func() {
			if bread {
				errC <- h.invoker(ctx, h.conn, req, h.pkg)
			} else if hal {
				_, err := h.hal9000.Dispatch(ctx, halMsg)
				h.logger.Printf("hal9000 request message=%s err=%s", msg.Text, err)
				errC <- err
			} else {
				errC <- errors.New("unhandled request")
			}
		}()
		var err error
		select {
		case <-ctx.Done():
			err = fmt.Errorf("RPC request failed to complete within %s", h.timeout)
		case err = <-errC:
		}
		if err != nil && req != nil && h.sender != nil && !strings.Contains(err.Error(), "no such service:") {
			_ = h.sender.Send(ctx, req.GetSource(), req.SenderId, &operator.Message{
				Text:    grpc.ErrorDesc(err),
				HTML:    fmt.Sprintf("Request failed: <code>%s</code>", grpc.ErrorDesc(err)),
				Options: &operatorhipchat.MessageOptions{Color: "red"},
			})
		}
	}(breadMatch, halMatch, req, msg, halMsg)
}

func (h *hipchat) getRequest(msg *operator.Message, senderID string) *operator.Request {
	matches := h.re.FindStringSubmatch(msg.Text)
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
	return &operator.Request{
		Call: &operator.Call{
			// TODO(sr) multi package support
			Service: fmt.Sprintf("%s.%s", h.pkg, operator.Camelize(matches[1], "-")),
			Method:  operator.Camelize(matches[2], "-"),
			Args:    args,
		},
		SenderId: senderID,
		Source:   msg.Source,
	}
}
