package operator_test

import (
	"bytes"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

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

type noopInstrumenter struct{}

func (i *noopInstrumenter) Instrument(*operator.Event) {}

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

func TestHandler(t *testing.T) {
	addr := "localhost:0"
	server := grpc.NewServer()
	defer server.GracefulStop()
	pingServer, err := operatortesting.NewAPIServer(
		&fakeReplier{},
		&operatortesting.PingerConfig{},
	)
	if err != nil {
		t.Fatal(err)
	}
	operatortesting.RegisterPingerServer(server, pingServer)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		t.Fatalf("Failed to listen: %v", err)
	}
	defer listener.Close()
	go server.Serve(listener)
	conn, err := grpc.Dial(listener.Addr().String(), grpc.WithInsecure())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	config := &operatorhipchat.ClientConfig{
		Hostname: "api.hipchat.test",
		Credentials: &operatorhipchat.ClientCredentials{
			ID:     "32a1811e-beee-4285-9df2-39c3a7971982",
			Secret: "rvHUrNmuAmJXW0liQo6CxF8Avj1kf5oy3BYE20Ju",
		},
	}
	store := &fakeStore{config}
	tArgs := make(map[string]string)
	tOTP := ""
	h, err := operator.NewHandler(
		context.Background(),
		3*time.Second,
		&noopInstrumenter{},
		operatorhipchat.NewRequestDecoder(store),
		"!",
		conn,
		func(ctx context.Context, conn *grpc.ClientConn, req *operator.Request) (bool, error) {
			tArgs = req.Call.Args
			tOTP = req.Otp
			return true, nil
		},
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
	}{
		{"!ping ping", 200, true, noArgs, ""},
		{"!ping ping foo=bar spam=\"boom town\" x='sup'", 200, true,
			map[string]string{"foo": "bar", "spam": "boom town", "x": "sup"}, ""},
		{"!ping ping", 400, false, noArgs, ""},
		{"!ping ping deadbeef", 200, true, noArgs, "deadbeef"},
		{"!ping ping x=\"y\" z=w deadbeef", 200, true,
			map[string]string{"x": "y", "z": "w"}, "deadbeef"},
		{"!ping", 404, true, noArgs, ""},
		{"!", 404, true, noArgs, ""},
		{" !ping ping", 404, true, noArgs, ""},
		{"ping", 404, true, noArgs, ""},
		{"", 404, true, noArgs, ""},
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
		req, err := http.NewRequest("POST", ts.URL, bytes.NewReader(data))
		if err != nil {
			t.Fatal(err)
		}
		req.Header.Add("Content-Type", "application/json")
		req.Header.Add("Authorization", "JWT "+token)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		defer resp.Body.Close()
		if resp.StatusCode != tt.status {
			t.Errorf("message `%s` expected status code %d, got %#v", tt.text, tt.status, resp.StatusCode)
		}
		if len(tt.args) != 0 {
			for key, val := range tArgs {
				s, ok := tt.args[key]
				if !ok {
					t.Errorf("message `%s` expected to have arg %s but didn't", tt.text, key)
				} else if s != val {
					t.Errorf("message `%s` expected to have arg `%s=\"%s\"` got %s", tt.text, key, val, s)
				}
			}
		}
		if tt.otp != "" && tOTP != tt.otp {
			t.Errorf("message `%s` expected to have OTP `%s` got `%s`", tt.text, tt.otp, tOTP)
		}
	}
}
