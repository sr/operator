package operator

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"time"
	"unicode"

	"golang.org/x/net/context"

	"google.golang.org/grpc"

	"github.com/golang/protobuf/ptypes"
)

const rCommandMessage = `\A%s(?P<service>\w+)\s+(?P<method>\w+)(?:\s+(?P<options>.*))?\z`

type handler struct {
	ctx          context.Context
	logger       Logger
	instrumenter Instrumenter
	authorizer   Authorizer
	decoder      Decoder
	re           *regexp.Regexp
	conn         *grpc.ClientConn
	invoker      Invoker
}

func newHandler(
	logger Logger,
	instrumenter Instrumenter,
	authorizer Authorizer,
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
		logger,
		instrumenter,
		authorizer,
		decoder,
		re,
		conn,
		invoker,
	}, nil
}

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	message, replierID, err := h.decoder.Decode(h.ctx, r)
	if err != nil {
		// TODO(sr) Log decoding error
		w.WriteHeader(http.StatusBadRequest)
		fmt.Printf("DEBUG decode error: %s\n", err)
		return
	}
	matches := h.re.FindStringSubmatch(message.Text)
	if matches == nil {
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
		Source:    message.Source,
	}
	if err := h.authorizer.Authorize(h.ctx, req); err != nil {
		// TODO(sr) Log unauthorized error
		fmt.Printf("DEBUG authorize error: %s\n", err)
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	start := time.Now()
	ok, err := h.invoker(h.ctx, h.conn, req, args)
	if !ok {
		// TODO(sr) Log unhandled message
		w.WriteHeader(http.StatusNotFound)
		return
	}
	if err != nil {
		req.Call.Error = &Error{Message: err.Error()}
	}
	req.Call.Duration = ptypes.DurationProto(time.Since(start))
	h.instrumenter.Instrument(req)
}
