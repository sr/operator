package bread

import (
	"database/sql"
	"fmt"
	"net/http"
	"runtime"
	"strings"
	"time"

	"git.dev.pardot.com/Pardot/bread/pb"
	"github.com/golang/protobuf/jsonpb"
	"github.com/golang/protobuf/ptypes"
)

type wrapperHandler struct {
	logger  Logger
	jsonpbm *jsonpb.Marshaler
	handler http.Handler
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

type pingHandler struct {
	db *sql.DB
}

func (h *pingHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	var payload string
	if req.URL.Query().Get("boomtown") != "" {
		panic("boomtown")
	}
	if err := h.db.Ping(); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		payload = `{"now": %d, "status": "failures"}`
	} else {
		payload = `{"now": %d, "status": "ok"}`
	}
	_, _ = w.Write([]byte(fmt.Sprintf(payload+"\n", time.Now().Unix())))
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
