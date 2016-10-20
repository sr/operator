package operatorhipchat

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/dvsekhvalnov/jose2go"
	"github.com/sr/operator"
	"golang.org/x/net/context"
)

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

type Room struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type requestDecoder struct {
	store ClientCredentialsStore
}

func newRequestDecoder(store ClientCredentialsStore) *requestDecoder {
	return &requestDecoder{store}
}

func (d *requestDecoder) Decode(ctx context.Context, req *http.Request) (*operator.Message, string, error) {
	var data Payload
	decoder := json.NewDecoder(req.Body)
	if err := decoder.Decode(&data); err != nil {
		return nil, "", err
	}
	auth := req.Header.Get("Authorization")
	if auth == "" {
		return nil, "", errors.New("no Authorization header")
	}
	parts := strings.Split(auth, " ")
	if len(parts) != 2 || parts[0] != "JWT" {
		return nil, "", errors.New("invalid Authorization header")
	}
	var config Clienter
	_, _, err := jose.Decode(parts[1], func(_ map[string]interface{}, payload string) interface{} {
		var data struct {
			Iss string
		}
		if err := json.Unmarshal([]byte(payload), &data); err != nil {
			return err
		}
		cfg, err := d.store.GetByOAuthID(data.Iss)
		if err != nil {
			return err
		}
		if cfg == nil {
			return ""
		}
		config = cfg
		return []byte(cfg.Secret())
	})
	if err != nil {
		return nil, "", err
	}
	client, err := config.Client(ctx)
	if err != nil {
		return nil, "", err
	}
	user, err := client.GetUser(ctx, data.Item.Message.From.ID)
	if err != nil {
		return nil, "", err
	}
	return &operator.Message{
		Text: data.Item.Message.Message,
		Source: &operator.Source{
			// TODO(sr) New SourceType
			Type: operator.SourceType_HUBOT,
			Room: &operator.Room{
				Id:   int64(data.Item.Room.ID),
				Name: data.Item.Room.Name,
			},
			User: &operator.User{
				Id:       strconv.Itoa(data.Item.Message.From.ID),
				Login:    data.Item.Message.From.MentionName,
				RealName: data.Item.Message.From.Name,
				Email:    user.Email,
			},
		},
	}, config.ID(), nil
}
