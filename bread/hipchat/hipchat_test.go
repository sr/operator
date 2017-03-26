package breadhipchat_test

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	jose "github.com/square/go-jose"

	"git.dev.pardot.com/Pardot/infrastructure/bread"
	"git.dev.pardot.com/Pardot/infrastructure/bread/hipchat"
	"golang.org/x/oauth2/clientcredentials"
)

type testMessageHandler struct {
	lastMessage string
}

func (h *testMessageHandler) Handle(msg *bread.ChatMessage) error {
	h.lastMessage = msg.Text
	return nil
}

func TestEventHandler(t *testing.T) {
	payload := `{
		"event": "room_message",
		"item": {
			"message": {
				"message": "hello world",
				"from": {
					"id": 42
				}
			}
		}
	}`

	t.Run("successful request", func(t *testing.T) {
		creds := &clientcredentials.Config{ClientID: "client ID", ClientSecret: "client secret"}
		handler := &testMessageHandler{}
		eventHandler, err := breadhipchat.EventHandler(nil, creds, handler.Handle)
		if err != nil {
			t.Fatal(err)
		}
		server := httptest.NewServer(eventHandler)
		signer, err := jose.NewSigner(jose.HS256, []byte(creds.ClientSecret))
		if err != nil {
			t.Fatal(err)
		}
		sig, err := signer.Sign([]byte(fmt.Sprintf(`{"iss": "%s"}`, creds.ClientID)))
		if err != nil {
			t.Fatal(err)
		}
		req, err := http.NewRequest(http.MethodPost, server.URL, strings.NewReader(payload))
		if err != nil {
			t.Fatal(err)
		}
		token, err := sig.CompactSerialize()
		if err != nil {
			t.Fatal(err)
		}
		req.Header.Add("Authorization", fmt.Sprintf("JWT %s", token))
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		if resp.StatusCode != http.StatusAccepted {
			v, err := ioutil.ReadAll(resp.Body)
			if err != nil {
				t.Fatal(err)
			}
			t.Errorf("want status code %d, got %d (body: %s)", http.StatusAccepted, resp.StatusCode, string(v))
		}
		if handler.lastMessage != "hello world" {
			t.Errorf(`want message "hello world", got "%s"`, handler.lastMessage)
		}
		server.Close()
	})
	t.Run("invalid JWT signature", func(t *testing.T) {
		creds := &clientcredentials.Config{ClientID: "client ID", ClientSecret: "client secret"}
		handler := &testMessageHandler{}
		eventHandler, err := breadhipchat.EventHandler(nil, creds, handler.Handle)
		if err != nil {
			t.Fatal(err)
		}
		server := httptest.NewServer(eventHandler)

		signer, err := jose.NewSigner(jose.HS256, []byte("garbage private key"))
		if err != nil {
			t.Fatal(err)
		}
		sig, err := signer.Sign([]byte(fmt.Sprintf(`{"iss": "%s"}`, creds.ClientID)))
		if err != nil {
			t.Fatal(err)
		}
		req, err := http.NewRequest(http.MethodPost, server.URL, strings.NewReader(payload))
		if err != nil {
			t.Fatal(err)
		}
		token, err := sig.CompactSerialize()
		if err != nil {
			t.Fatal(err)
		}
		req.Header.Add("Authorization", fmt.Sprintf("JWT %s", token))
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		if resp.StatusCode != http.StatusBadRequest {
			v, err := ioutil.ReadAll(resp.Body)
			if err != nil {
				t.Fatal(err)
			}
			t.Errorf("want status code %d, got %d (body: %s)", http.StatusAccepted, resp.StatusCode, string(v))
		}
		if handler.lastMessage != "" {
			t.Errorf(`want message "", got "%s"`, handler.lastMessage)
		}
		server.Close()
	})
}
