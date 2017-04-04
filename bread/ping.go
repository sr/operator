package bread

import (
	"database/sql"
	"fmt"
	"net/http"
	"time"
)

// NewPingHandler returns an http.HandlerFunc that implements a simple health
// check endpoint for use with ELB and the likes. If the given db connection
// is not nil, this also checks the availability of the database.
func NewPingHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, req *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=UTF-8")
		// This is helpful to test the behaviour of the server when it panics.
		if req.URL.Query().Get("boomtown") != "" {
			panic("boomtown")
		}
		payload := `{"now": %d, "status": "ok"}`
		if db != nil {
			if err := db.Ping(); err != nil {
				w.WriteHeader(http.StatusInternalServerError)
				payload = `{"now": %d, "status": "failures"}`
			}
		}
		_, _ = w.Write([]byte(fmt.Sprintf(payload+"\n", time.Now().Unix())))
	}
}
