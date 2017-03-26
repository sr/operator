package bread

import (
	"database/sql"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"git.dev.pardot.com/Pardot/infrastructure/bread/pb"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"golang.org/x/net/context"
)

type pingServer struct {
	operator.Sender
}

// NewPingServer returns a gRPC server that implements the breadpb.PingServer
// interface which can be used a simple "health check" endpoint.
func NewPingServer(sender operator.Sender) breadpb.PingServer {
	return &pingServer{sender}
}

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

func (s *pingServer) Ping(ctx context.Context, req *breadpb.PingRequest) (*operator.Response, error) {
	email := operator.GetUserEmail(req)
	if email == "" {
		email = "unknown"
	}
	return operator.Reply(ctx, s, req, &operator.Message{
		Text: fmt.Sprintf("PONG %s", email),
		HTML: fmt.Sprintf(`PONG <a href="mailto:%s">%s</a>`, email, email),
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.Ping",
		},
	})
}

func (s *pingServer) SlowLoris(ctx context.Context, req *breadpb.SlowLorisRequest) (*operator.Response, error) {
	var dur time.Duration
	if req.Wait == "" {
		dur = 10 * time.Second
	} else {
		i, err := strconv.Atoi(req.Wait)
		if err != nil {
			return nil, err
		}
		dur = time.Duration(i) * time.Second
	}
	time.Sleep(dur)
	return operator.Reply(ctx, s, req, &operator.Message{
		Text: "https://66.media.tumblr.com/500736338e23d5b5adb0201b6b74cbc9/tumblr_mmyemrrqkq1s1fx0zo1_500.gif",
		Options: &operatorhipchat.MessageOptions{
			Color: "gray",
			From:  "pinger.SlowLoris",
		},
	})
}
