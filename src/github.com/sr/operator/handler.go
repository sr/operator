package operator

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"unicode"

	"golang.org/x/net/context"

	"google.golang.org/grpc"
)

const rCommandMessage = `\A%s(?P<service>\w+)\s+(?P<method>\w+)(?:\s+(?P<options>.*))?\z`

type handler struct {
	ctx     context.Context
	inst    Instrumenter
	decoder Decoder
	re      *regexp.Regexp
	conn    *grpc.ClientConn
	invoker Invoker
}

func newHandler(
	inst Instrumenter,
	decoder Decoder,
	prefix string,
	conn *grpc.ClientConn,
	invoker Invoker,
) (*handler, error) {
	re, err := regexp.Compile(fmt.Sprintf(rCommandMessage, regexp.QuoteMeta(prefix)))
	if err != nil {
		return nil, err
	}
	return &handler{
		context.Background(),
		inst,
		decoder,
		re,
		conn,
		invoker,
	}, nil
}

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	msg, replierID, err := h.decoder.Decode(h.ctx, r)
	if err != nil {
		h.inst.Instrument(&Event{Key: "handler_decode_error", Error: err})
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	matches := h.re.FindStringSubmatch(msg.Text)
	if matches == nil {
		h.inst.Instrument(&Event{Key: "handler_ignored_message", Message: msg})
		w.WriteHeader(http.StatusNotFound)
		return
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
	req := &Request{
		Call: &Call{
			Service: matches[1],
			Method:  matches[2],
		},
		Otp:       otp,
		ReplierId: replierID,
		Source:    msg.Source,
	}
	ok, err := h.invoker(h.ctx, h.conn, req, args)
	if !ok {
		h.inst.Instrument(&Event{
			Key:     "handler_unhandled_message",
			Message: msg,
			Request: req,
			Args:    args,
			Error:   err,
		})
		w.WriteHeader(http.StatusNotFound)
		return
	}
}
