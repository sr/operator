package operatorhipchat

import (
	"encoding/json"
	"net/http"

	"github.com/sr/operator"
)

type requestDecoder struct{}

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
	ID          string `json:"id"`
	Name        string `json:"name"`
	MentionName string `json:"mention_name"`
}

type Room struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

func NewRequestDecoder() *requestDecoder {
	return &requestDecoder{}
}

func (d *requestDecoder) Decode(req *http.Request) (*operator.Message, error) {
	var data Payload
	decoder := json.NewDecoder(req.Body)
	if err := decoder.Decode(&data); err != nil {
		return nil, err
	}
	// TODO(sr) Verify JWT signature of the request
	return &operator.Message{
		Text: data.Item.Message.Message,
		Source: &operator.Source{
			// TODO(sr) New SourceType
			Type: operator.SourceType_HUBOT,
			Room: &operator.Room{
				Name: data.Item.Room.Name,
			},
			User: &operator.User{
				Id:       data.Item.Message.From.ID,
				Login:    data.Item.Message.From.MentionName,
				RealName: data.Item.Message.From.Name,
				Email:    "",
			},
			Hostname: "",
		},
	}, nil
}
