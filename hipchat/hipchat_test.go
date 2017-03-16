package breadhipchat_test

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	jose "github.com/square/go-jose"

	"git.dev.pardot.com/Pardot/bread/hipchat"
	"golang.org/x/oauth2/clientcredentials"
)

type testMessageHandler struct {
	lastMessage string
}

func (h *testMessageHandler) Handle(msg *breadhipchat.Item) error {
	h.lastMessage = msg.Message.Message
	return nil
}

func TestEventHandler(t *testing.T) {
	payload := `{
		"event": "room_message",
		"item": {
			"message": {
				"message": "hello world"
			}
		}
	}`

	t.Run("successful request", func(t *testing.T) {
		creds := &clientcredentials.Config{ClientID: "client ID", ClientSecret: "client secret"}
		handler := &testMessageHandler{}
		eventHandler, err := breadhipchat.EventHandler(creds, handler.Handle)
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
			t.Errorf("want status code %d, got %d", http.StatusAccepted, resp.StatusCode)
		}
		if handler.lastMessage != "hello world" {
			t.Errorf(`want message "hello world", got "%s"`, handler.lastMessage)
		}
		server.Close()
	})
	t.Run("invalid JWT signature", func(t *testing.T) {
		creds := &clientcredentials.Config{ClientID: "client ID", ClientSecret: "client secret"}
		handler := &testMessageHandler{}
		eventHandler, err := breadhipchat.EventHandler(creds, handler.Handle)
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
			t.Errorf("want status code %d, got %d", http.StatusBadRequest, resp.StatusCode)
		}
		if handler.lastMessage != "" {
			t.Errorf(`want message "", got "%s"`, handler.lastMessage)
		}
		server.Close()
	})
}
