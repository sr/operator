package operator_test

import (
	"bytes"
	"encoding/json"
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"

	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"github.com/dvsekhvalnov/jose2go"
	"github.com/sr/operator"
	"github.com/sr/operator/hipchat"
	"github.com/sr/operator/testing"
)

var credentials = &operatorhipchat.ClientCredentials{
	ID:     "32a1811e-beee-4285-9df2-39c3a7971982",
	Secret: "rvHUrNmuAmJXW0liQo6CxF8Avj1kf5oy3BYE20Ju",
}

type fakeInstrumenter struct {
	events []*operator.Event
}

func (i *fakeInstrumenter) Instrument(ev *operator.Event) {
	i.events = append(i.events, ev)
}

func (i *fakeInstrumenter) pop() (ev *operator.Event) {
	if len(i.events) == 0 {
		return nil
	}
	ev, i.events = i.events[len(i.events)-1], i.events[:len(i.events)-1]
	return ev
}

type fakeAuthorizer struct {
	err error
}

func (a *fakeAuthorizer) Authorize(context.Context, *operator.Request) error {
	return a.err
}

type fakeReplier struct{}

func (c *fakeReplier) Reply(_ context.Context, _ *operator.Source, _ string, _ *operator.Message) error {
	return nil
}

type fakeStore struct {
	config *operatorhipchat.ClientConfig
}

func (s *fakeStore) GetByOAuthID(_ string) (operatorhipchat.Clienter, error) {
	return &fakeClientConfig{s.config}, nil
}

func (s *fakeStore) Create(_ *operatorhipchat.ClientCredentials) error {
	return nil
}

type fakeClientConfig struct {
	config *operatorhipchat.ClientConfig
}

func (c *fakeClientConfig) ID() string {
	return credentials.ID
}

func (c *fakeClientConfig) Secret() string {
	return credentials.Secret
}

func (c *fakeClientConfig) Client(_ context.Context) (operatorhipchat.Client, error) {
	return &fakeHipchatClient{}, nil
}

type fakeHipchatClient struct{}

func (c *fakeHipchatClient) GetUser(_ context.Context, id int) (*operatorhipchat.User, error) {
	return &operatorhipchat.User{
		ID:    id,
		Email: "jane@salesforce.com",
	}, nil
}

func (c *fakeHipchatClient) SendRoomNotification(_ context.Context, _ *operatorhipchat.RoomNotification) error {
	return nil
}

type invocation struct {
	msg *operator.Message
	req *operator.Request
}

type invoker struct {
	conn  *grpc.ClientConn
	invoC chan *invocation
}

func (i *invoker) Invoke(ctx context.Context, msg *operator.Message, req *operator.Request) {
	i.invoC <- &invocation{msg, req}
}

func TestOperator(t *testing.T) {
	auth := &fakeAuthorizer{}
	inst := &fakeInstrumenter{}
	server := grpc.NewServer(grpc.UnaryInterceptor(operator.NewUnaryServerInterceptor(auth, inst)))
	defer server.GracefulStop()
	operatortesting.RegisterPingerServer(server, operatortesting.NewServer(&fakeReplier{}))
	listener, err := net.Listen("tcp", "localhost:0")
	if err != nil {
		t.Fatalf("failed to listen: %v", err)
	}
	defer listener.Close()
	go server.Serve(listener)
	conn, err := grpc.Dial(
		listener.Addr().String(),
		grpc.WithInsecure(),
		grpc.WithBlock(),
	)
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	t.Run("UnaryServerInterceptor", func(t *testing.T) {
		client := operatortesting.NewPingerClient(conn)
		authErr := errors.New("unauthorized")
		pingReq := &operatortesting.PingRequest{&operator.Request{}}
		for _, tc := range []struct {
			call    *operator.Call
			req     *operatortesting.PingRequest
			authErr error
			err     error
			key     string
			invReq  bool
		}{
			{&operator.Call{Service: "testing.Pinger", Method: "Ping"},
				pingReq, nil, nil, "request_handled", false},
			{&operator.Call{Service: "testing.Pinger", Method: "PingPong"},
				pingReq, nil, nil, "request_handled", false},
			{&operator.Call{Service: "testing.Pinger", Method: "Ping"},
				pingReq, authErr, authErr, "request_unauthorized", false},
			{&operator.Call{Service: "testing.Pinger", Method: "Ping"},
				&operatortesting.PingRequest{}, nil, operator.ErrInvalidRequest, "", false},
		} {
			auth.err = tc.authErr
			switch tc.call.Method {
			case "Ping":
				_, err = client.Ping(context.Background(), tc.req)
			case "PingPong":
				_, err = client.PingPong(context.Background(), tc.req)
			default:
				t.Fatalf("unable to handle test case")
			}
			if err != nil && tc.err != nil && grpc.ErrorDesc(err) != tc.err.Error() {
				t.Errorf("expected err %s, got %s", tc.err, err)
			}
			ev := inst.pop()
			if tc.key != "" {
				if ev.Key != tc.key {
					t.Errorf("expect event.Key to equal %s, got %s", tc.key, ev.Key)
				}
				if ev.Error != tc.err {
					t.Errorf("expect event.Error to equal %s, got %s", tc.err, ev.Error)
				}
				if ev.Request.Call.Service != tc.call.Service || ev.Request.Call.Method != tc.call.Method {
					t.Errorf("expect event with call %s/%s, got %s/%s", tc.call.Service,
						tc.call.Method, ev.Request.Call.Service, ev.Request.Call.Method)
				}
			} else if ev != nil {
				t.Fatalf("expected no event, got event.Key = %s", ev.Key)
			}
		}
	})
	t.Run("Handler", func(t *testing.T) {
		inv := &invoker{
			conn:  conn,
			invoC: make(chan *invocation, 1),
		}
		config := &operatorhipchat.ClientConfig{
			Hostname: "api.hipchat.test",
			Credentials: &operatorhipchat.ClientCredentials{
				ID:     "32a1811e-beee-4285-9df2-39c3a7971982",
				Secret: "rvHUrNmuAmJXW0liQo6CxF8Avj1kf5oy3BYE20Ju",
			},
		}
		store := &fakeStore{config}
		h, err := operator.NewHandler(
			context.Background(),
			inst,
			operatorhipchat.NewRequestDecoder(store),
			inv,
			"testing",
			"!",
		)
		if err != nil {
			t.Fatal(err)
		}
		ts := httptest.NewServer(h)
		noArgs := make(map[string]string)
		for _, tt := range []struct {
			text   string
			status int
			jwt    bool
			args   map[string]string
			otp    string
			call   *operator.Call
		}{
			{"!ping ping", 200, true, noArgs, "", &operator.Call{Service: "testing.Ping", Method: "Ping"}},
			{"!ping ping-pong", 200, true, noArgs, "", &operator.Call{Service: "testing.Ping", Method: "PingPong"}},
			{"!ping ping foo=bar spam=\"boom town\" x='sup'", 200, true,
				map[string]string{"foo": "bar", "spam": "boom town", "x": "sup"}, "", nil},
			{"!ping ping", 400, false, noArgs, "", nil},
			{"!ping ping deadbeef", 200, true, noArgs, "deadbeef", nil},
			{"!ping ping x=\"y\" z=w deadbeef", 200, true,
				map[string]string{"x": "y", "z": "w"}, "deadbeef", nil},
			{"!ping", 404, true, noArgs, "", nil},
			{"!", 404, true, noArgs, "", nil},
			{" !ping ping", 404, true, noArgs, "", nil},
			{"ping", 404, true, noArgs, "", nil},
			{"", 404, true, noArgs, "", nil},
		} {
			webhook := &operatorhipchat.Payload{
				Event: "room_message",
				Item: &operatorhipchat.Item{
					Message: &operatorhipchat.Message{
						Message: tt.text,
						From: &operatorhipchat.User{
							ID:          1,
							MentionName: "breadsignal",
							Name:        "Breadman",
						},
					},
					Room: &operatorhipchat.Room{
						ID:   1,
						Name: "BREAD",
					},
				},
			}
			data, err := json.Marshal(webhook)
			if err != nil {
				t.Fatal(err)
			}
			var token string
			if tt.jwt == false {
				token = "bogus"
			} else {
				token, err = jose.Sign("{}", jose.HS256, []byte(config.Credentials.Secret))
				if err != nil {
					t.Fatal(err)
				}
			}
			httpReq, err := http.NewRequest("POST", ts.URL, bytes.NewReader(data))
			if err != nil {
				t.Fatal(err)
			}
			httpReq.Header.Add("Content-Type", "application/json")
			httpReq.Header.Add("Authorization", "JWT "+token)
			resp, err := http.DefaultClient.Do(httpReq)
			if err != nil {
				t.Fatal(err)
			}
			defer resp.Body.Close()
			if resp.StatusCode != tt.status {
				t.Errorf("message `%s` expected status code %d, got %#v", tt.text, tt.status, resp.StatusCode)
			}
			switch resp.StatusCode {
			case 404:
				ev := inst.pop()
				if ev.Key != "handler_unmatched_message" {
					t.Errorf("message `%s` expected to produce instrumentation event `handler_unmatched_message`, got `%s`", tt.text, ev.Key)
				}
			case 400:
				ev := inst.pop()
				if ev.Key != "handler_decode_error" {
					t.Errorf("message `%s` expected to produce instrumentation event `handler_decode_error`, got `%s`", tt.text, ev.Key)
				}
			case 200:
				invoc := <-inv.invoC
				if len(tt.args) != 0 {
					for key, val := range invoc.req.Call.Args {
						s, ok := tt.args[key]
						if !ok {
							t.Errorf("message `%s` expected to have arg %s but didn't", tt.text, key)
						} else if s != val {
							t.Errorf("message `%s` expected to have arg `%s=\"%s\"` got %s", tt.text, key, val, s)
						}
					}
				}
				if tt.otp != "" && invoc.req.Otp != tt.otp {
					t.Errorf("message `%s` expected to have OTP `%s` got `%s`", tt.text, tt.otp, invoc.req.Otp)
				}
				if tt.call != nil {
					if invoc.req.Call.Service != tt.call.Service || invoc.req.Call.Method != tt.call.Method {
						t.Errorf(
							"message `%s` expected to map to call=/%s/%s, got call=/%s/%s",
							tt.text, tt.call.Service, tt.call.Method, invoc.req.Call.Service, invoc.req.Call.Method,
						)
					}
				}
			default:
				t.Errorf("message `%s` with jwt=%v resulted in unhandled status code %d", tt.text, tt.jwt, resp.StatusCode)
			}
		}
	})
}
