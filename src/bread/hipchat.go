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

	"google.golang.org/grpc"

	"github.com/sr/operator"
	"github.com/sr/operator/generator"

	"bread/hal"
)

type hipchat struct {
	ctx     context.Context
	inst    operator.Instrumenter
	decoder operator.Decoder
	invoker operator.InvokerFunc
	conn    *grpc.ClientConn
	hal     breadhal.RobotClient
	timeout time.Duration
	re      *regexp.Regexp
	pkg     string
}

func (h *hipchat) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	msg, replierID, err := h.decoder.Decode(h.ctx, r)
	if err != nil || msg.Text == "" {
		h.inst.Instrument(&operator.Event{Key: "handler_decode_error", Error: err})
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	var (
		req    *operator.Request
		halMsg = &breadhal.Message{Text: msg.Text}
	)
	req = h.getRequest(msg, replierID)
	if resp, err := h.hal.IsMatch(h.ctx, halMsg); err != nil || !resp.Match {
		halMsg = nil
	}
	if req != nil && halMsg != nil {
		fmt.Println("WARN: both HAL9K and Operator match. HAL9K will be ignored")
	}
	if req == nil && halMsg == nil {
		h.inst.Instrument(&operator.Event{Key: "handler_unmatched_message", Message: msg})
		w.WriteHeader(http.StatusNotFound)
		return
	}
	go func(req *operator.Request, msg *breadhal.Message) {
		ctx, cancel := context.WithTimeout(h.ctx, h.timeout)
		defer cancel()
		errC := make(chan error, 1)
		go func() {
			if req != nil {
				errC <- h.invoker(ctx, h.conn, req, h.pkg)
			} else if msg != nil {
				_, err := h.hal.Dispatch(ctx, msg)
				errC <- err
			}
			errC <- errors.New("not found")
		}()
		var err error
		select {
		case <-ctx.Done():
			err = fmt.Errorf("RPC request failed to complete within %s", h.timeout)
		case err := <-errC:
			err = err
		}
	}(req, halMsg)
}

func (h *hipchat) getRequest(msg *operator.Message, replierID string) *operator.Request {
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
		Otp:       otp,
		ReplierId: replierID,
		Source:    msg.Source,
	}
}
