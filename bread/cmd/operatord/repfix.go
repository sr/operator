package main

import (
	"context"
	"net/http"

	"git.dev.pardot.com/Pardot/infrastructure/bread/pb/hal9000"
)

// NewRepfixHandler returns an http.HandlerFunc that receives request from
// the repfix client running inside the datacenters and forwards them to
// the HAL9000 gRPC service.
func newRepfixHandler(hal hal9000.RobotClient) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "GET":
			w.WriteHeader(http.StatusOK)
		case "POST":
			if err := r.ParseMultipartForm(1000000); err != nil {
				w.WriteHeader(http.StatusInternalServerError)
				_, _ = w.Write([]byte(err.Error()))
			} else {
				resp, err := hal.CreateRepfixError(context.TODO(), &hal9000.CreateRepfixErrorRequest{
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
}
