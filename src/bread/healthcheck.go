package bread

import (
	"database/sql"
	"fmt"
	"net/http"
	"time"
)

type pingHandler struct {
	db *sql.DB
}

func newPingHandler(db *sql.DB) *pingHandler {
	return &pingHandler{db}
}

func (h *pingHandler) ServeHTTP(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	var payload string
	if err := h.db.Ping(); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		payload = `{"now": %d, "status": "failures"}`
	} else {
		payload = `{"now": %d, "status": "ok"}`
	}
	_, _ = w.Write([]byte(fmt.Sprintf(payload+"\n", time.Now().Unix())))
}
