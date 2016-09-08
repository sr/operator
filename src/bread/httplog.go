package bread

import (
	"fmt"
	"net/http"
	"runtime"
	"strings"
	"time"

	"github.com/golang/protobuf/ptypes"
	"github.com/sr/operator/protolog"
)

type wrapperHandler struct {
	logger  protolog.Logger
	handler http.Handler
}

func (h *wrapperHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	start := time.Now()
	ww := &responseWriter{w, 0, nil}
	defer func() {
		var errS string
		if ww.writeError != nil {
			errS = ww.writeError.Error()
		} else {
			errS = ""
		}
		var statusCode int
		if ww.statusCode == 0 {
			statusCode = http.StatusOK
		} else {
			statusCode = ww.statusCode
		}
		log := &HTTPRequest{
			Method:     req.Method,
			StatusCode: uint32(statusCode),
			Error:      errS,
		}
		if req.URL != nil {
			log.Path = req.URL.Path
			log.Query = valuesMap(req.URL.Query())
		}
		if r := recover(); r != nil {
			ww.WriteHeader(http.StatusInternalServerError)
			stack := make([]byte, 8192)
			stack = stack[:runtime.Stack(stack, false)]
			log.Error = fmt.Sprintf("panic: %v\n%s", r, string(stack))
		}
		log.Duration = ptypes.DurationProto(time.Since(start))
		h.logger.Info(log)
	}()
	h.handler.ServeHTTP(ww, req)
}

type responseWriter struct {
	http.ResponseWriter
	statusCode int
	writeError error
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
