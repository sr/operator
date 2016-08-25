package operatorhipchat

import (
	"database/sql"
	"net/http"
	"net/url"

	"github.com/sr/operator"
	"golang.org/x/net/context"
)

var DefaultScopes = []string{"send_message", "send_notification"}

type Client interface {
	GetUser(context.Context, int) (*User, error)
	SendRoomNotification(context.Context, *RoomNotification) error
}

type ClientCredentialsStore interface {
	Create(*ClientCredentials) error
	GetByOAuthID(string) (*ClientCredentials, error)
}

type AddonConfig struct {
	Namespace         string
	URL               *url.URL
	Homepage          string
	WebhookURL        *url.URL
	WebhookPrefix     string
	APIConsumerScopes []string
}

type ClientConfig struct {
	Hostname    string
	Token       string
	Credentials *ClientCredentials
	Scopes      []string
}

type ClientCredentials struct {
	ID     string
	Secret string
}

type MessageOptions struct {
	Color string `json:"color"`
	From  string `json:"from"`
}

type RoomNotification struct {
	*MessageOptions
	Color         string `json:"color"`
	From          string `json:"from"`
	Message       string `json:"message"`
	MessageFormat string `json:"message_format"`
	RoomID        int64  `json:"-"`
}

type User struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Email       string `json:"email"`
	Deleted     bool   `json:"is_deleted"`
	MentionName string `json:"mention_name"`
}

func NewAddonHandler(store ClientCredentialsStore, config *AddonConfig) http.Handler {
	return newAddonHandler(store, config)
}

func NewClient(ctx context.Context, config *ClientConfig) (Client, error) {
	return newClient(ctx, config)
}

func NewReplier(store ClientCredentialsStore, hostname string) operator.Replier {
	return newReplier(store, hostname)
}

func NewRequestDecoder(store ClientCredentialsStore, hostname string) operator.Decoder {
	return newRequestDecoder(store, hostname)
}

func NewSQLStore(db *sql.DB) ClientCredentialsStore {
	return newSQLStore(db)
}
