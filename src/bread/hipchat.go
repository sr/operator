package bread

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"time"
	"unicode"

	"github.com/sr/operator"
	"github.com/sr/operator/generator"
	"github.com/sr/operator/hipchat"
	"google.golang.org/grpc"

	"bread/hal9000"
)

type hipchat struct {
	ctx     context.Context
	inst    operator.Instrumenter
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
		h.inst.Instrument(&operator.Event{Key: "handler_decode_error", Error: err})
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	var (
		opMatch, halMatch bool
		req               = h.getRequest(msg, senderID)
		halMsg            = &hal9000.Message{Text: msg.Text}
	)
	if req != nil {
		if svc, ok := h.svcInfo[req.Call.Service]; ok {
			for _, m := range svc.Methods {
				if m.Name == req.Call.Method {
					opMatch = true
					break
				}
			}
		}
	}
	if r, err := h.hal9000.IsMatch(h.ctx, halMsg); err != nil && r.Match {
		halMatch = true
	}
	if opMatch && halMatch {
		fmt.Println("WARN: both HAL9K and Operator match. HAL9K will be ignored")
	}
	if !opMatch && halMsg == nil {
		h.inst.Instrument(&operator.Event{Key: "handler_unmatched_message", Message: msg})
		w.WriteHeader(http.StatusNotFound)
		return
	}
	go func(req *operator.Request, msg *hal9000.Message) {
		ctx, cancel := context.WithTimeout(h.ctx, h.timeout)
		defer cancel()
		errC := make(chan error, 1)
		go func() {
			if req != nil {
				errC <- h.invoker(ctx, h.conn, req, h.pkg)
			} else if msg != nil {
				_, err := h.hal9000.Dispatch(ctx, msg)
				errC <- err
			}
			errC <- errors.New("unhandled request")
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
	}(req, halMsg)
}

func (h *hipchat) getRequest(msg *operator.Message, senderID string) *operator.Request {
	matches := h.re.FindStringSubmatch(msg.Text)
	if matches != nil {
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
	var otp string
	if len(words) != 0 && !strings.Contains(words[len(words)-1], "=") {
		otp, words = words[len(words)-1], words[:len(words)-1]
	}
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
			Service: fmt.Sprintf("%s.%s", h.pkg, generator.Camelize(matches[1], "-")),
			Method:  generator.Camelize(matches[2], "-"),
			Args:    args,
		},
		Otp:      otp,
		SenderId: senderID,
		Source:   msg.Source,
	}
}
