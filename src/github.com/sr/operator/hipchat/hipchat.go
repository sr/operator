package operatorhipchat

import "github.com/sr/operator"

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

func NewRequestDecoder(store OAuthClientStore) operator.RequestDecoder {
	return newRequestDecoder(store)
}
