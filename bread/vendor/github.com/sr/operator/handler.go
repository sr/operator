package operator

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"unicode"

	"golang.org/x/net/context"
)

type handler struct {
	ctx     context.Context
	inst    Instrumenter
	decoder Decoder
	invoker Invoker
	re      *regexp.Regexp
	pkg     string
}

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	msg, senderID, err := h.decoder.Decode(h.ctx, r)
	if err != nil {
		h.inst.Instrument(&Event{Key: "handler_decode_error", Error: err})
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	matches := h.re.FindStringSubmatch(msg.Text)
	if matches == nil {
		h.inst.Instrument(&Event{Key: "handler_unmatched_message", Message: msg})
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
	go h.invoker.Invoke(
		h.ctx,
		msg,
		&Request{
			Call: &Call{
				// TODO(sr) multi package support
				Service: fmt.Sprintf("%s.%s", h.pkg, Camelize(matches[1], "-")),
				Method:  Camelize(matches[2], "-"),
				Args:    args,
			},
			Otp:      otp,
			SenderId: senderID,
			Source:   msg.Source,
		},
	)
}
