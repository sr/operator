package bread

import (
	"context"
	"net/http"

	"git.dev.pardot.com/Pardot/bread/pb/hal9000"
)

type repfixHandler struct {
	hal hal9000.RobotClient
}

func (h *repfixHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		w.WriteHeader(http.StatusOK)
	case "POST":
		if err := r.ParseMultipartForm(1000000); err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			_, _ = w.Write([]byte(err.Error()))
		} else {
			resp, err := h.hal.CreateRepfixError(context.TODO(), &hal9000.CreateRepfixErrorRequest{
				Hostname:       r.FormValue("hostname"),
				Error:          r.FormValue("error"),
				MysqlLastError: r.FormValue("mysql_last_error"),
			})
			if err != nil {
				w.WriteHeader(http.StatusInternalServerError)
				_, _ = w.Write([]byte(err.Error()))
			} else {
				w.WriteHeader(int(resp.Status))
				_, _ = w.Write([]byte(resp.Body))
			}
		}
	default:
		w.WriteHeader(http.StatusNotFound)
	}
}
