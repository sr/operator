package bread

import (
	"fmt"
	"net/http"
	"runtime"
	"strings"
	"time"

	"github.com/golang/protobuf/jsonpb"
	"github.com/golang/protobuf/ptypes"

	"git.dev.pardot.com/Pardot/infrastructure/bread/pb"
)

// NewHandler returns an http.Handler that logs all requests, inlude those that
// cause a panic in the wrapped handler.
func NewHandler(logger Logger, handler http.Handler) http.Handler {
	return &wrapperHandler{logger, &jsonpb.Marshaler{}, handler}
}

type wrapperHandler struct {
	logger  Logger
	jsonpbm *jsonpb.Marshaler
	handler http.Handler
}

type responseWriter struct {
	http.ResponseWriter
	statusCode int
	writeError error
}

func (h *wrapperHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	start := time.Now()
	wrappedW := &responseWriter{w, 0, nil}
	defer func() {
		var errS string
		if wrappedW.writeError != nil {
			errS = wrappedW.writeError.Error()
		} else {
			errS = ""
		}
		var statusCode int
		if wrappedW.statusCode == 0 {
			statusCode = http.StatusOK
		} else {
			statusCode = wrappedW.statusCode
		}
		log := &breadpb.HTTPRequest{
			Method:     req.Method,
			StatusCode: uint32(statusCode),
			Error:      errS,
		}
		if req.URL != nil {
			log.Path = req.URL.Path
			log.Query = valuesMap(req.URL.Query())
		}
		if r := recover(); r != nil {
			wrappedW.WriteHeader(http.StatusInternalServerError)
			stack := make([]byte, 8192)
			stack = stack[:runtime.Stack(stack, false)]
			log.Error = fmt.Sprintf("panic: %v\n%s", r, string(stack))
		}
		log.Duration = ptypes.DurationProto(time.Since(start))
		jsonlog, err := h.jsonpbm.MarshalToString(log)
		if err != nil {
			h.logger.Printf("error marshaling log line: %s", err)
		}
		h.logger.Println(jsonlog)
	}()
	h.handler.ServeHTTP(wrappedW, req)
}

func (w *responseWriter) Write(p []byte) (int, error) {
	n, err := w.ResponseWriter.Write(p)
	w.writeError = err
	return n, err
}

func (w *responseWriter) WriteHeader(statusCode int) {
	w.statusCode = statusCode
	w.ResponseWriter.WriteHeader(statusCode)
}

func valuesMap(values map[string][]string) map[string]string {
	if values == nil {
		return nil
	}
	m := make(map[string]string)
	for key, value := range values {
		m[key] = strings.Join(value, " ")
	}
	return m
}
