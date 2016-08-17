package operatorhipchat

import (
	"crypto/x509"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"

	"golang.org/x/oauth2/jws"

	"github.com/sr/operator"
)

type OAuthClientStore interface {
	GetByAddonID(string) (*OAuthClient, error)
	GetByOAuthID(string) (*OAuthClient, error)
	PutByAddonID(string, *OAuthClient) error
}

type OAuthClient struct {
	ID     string
	Secret string
}

type Payload struct {
	Event string `json:"event"`
	Item  *Item  `json:"item"`
}

type Item struct {
	Message *Message `json:"message"`
	Room    *Room    `json:"room"`
}

type Message struct {
	Message string `json:"message"`
	From    *User  `json:"from"`
}

type User struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	MentionName string `json:"mention_name"`
}

type Room struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type requestDecoder struct {
	store OAuthClientStore
}

func NewRequestDecoder(store OAuthClientStore) operator.RequestDecoder {
	return &requestDecoder{store}
}

func (d *requestDecoder) Decode(req *http.Request) (*operator.Message, error) {
	var data Payload
	decoder := json.NewDecoder(req.Body)
	if err := decoder.Decode(&data); err != nil {
		return nil, err
	}
	auth := req.Header.Get("Authorization")
	if auth == "" {
		return nil, errors.New("no Authorization header")
	}
	parts := strings.Split(auth, " ")
	if len(parts) != 2 || parts[0] != "JWT" {
		return nil, errors.New("invalid Authorization header")
	}
	claim, err := jws.Decode(parts[1])
	if err != nil {
		return nil, err
	}
	oauthClient, err := d.store.GetByOAuthID(claim.Iss)
	if err != nil {
		return nil, err
	}
	key, err := x509.ParsePKCS1PrivateKey([]byte(oauthClient.Secret))
	if err != nil {
		return nil, err
	}
	if err := jws.Verify(parts[1], &key.PublicKey); err != nil {
		return nil, err
	}
	return &operator.Message{
		Text: data.Item.Message.Message,
		Source: &operator.Source{
			// TODO(sr) New SourceType
			Type: operator.SourceType_HUBOT,
			Room: &operator.Room{
				Name: data.Item.Room.Name,
			},
			User: &operator.User{
				Id:       strconv.Itoa(data.Item.Message.From.ID),
				Login:    data.Item.Message.From.MentionName,
				RealName: data.Item.Message.From.Name,
				Email:    "",
			},
			Hostname: "",
		},
	}, nil
}
