package operator

import (
	"fmt"
	"net/http"
	"regexp"
	"time"

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
		return
	}
	matches := h.re.FindStringSubmatch(message.Text)
	if matches == nil {
		w.WriteHeader(http.StatusNotFound)
		return
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
		return
	}
	start := time.Now()
	ok, err := h.invoker(h.conn, req)
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
