package breadping

import "github.com/sr/operator"

func NewAPIServer(chat operator.ChatClient, config *PingerConfig) (PingerServer, error) {
	return &apiServer{config, chat}, nil
}
