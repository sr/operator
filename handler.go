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
	logger       Logger
	instrumenter Instrumenter
	authorizer   Authorizer
	decoder      RequestDecoder
	re           *regexp.Regexp
	conn         *grpc.ClientConn
	invoker      Invoker
}

func newHandler(
	logger Logger,
	instrumenter Instrumenter,
	authorizer Authorizer,
	decoder RequestDecoder,
	prefix string,
	conn *grpc.ClientConn,
	invoker Invoker,
) (*handler, error) {
	// TODO(sr) Quote the prefix with regexp.QuoteMeta
	re, err := regexp.Compile(fmt.Sprintf(rCommandMessage, prefix))
	if err != nil {
		return nil, err
	}
	return &handler{
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
	message, err := h.decoder.Decode(r)
	if err != nil {
		// TODO(sr) Log decoding error
		w.WriteHeader(http.StatusBadRequest)
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
		Source: message.Source,
	}
	if err := h.authorizer.Authorize(req); err != nil {
		// TODO(sr) Log unauthorized error
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	start := time.Now()
	ok, err := h.invoker(context.Background(), h.conn, req, args)
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
