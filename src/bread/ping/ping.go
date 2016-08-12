package breadping

import "bread"

func NewAPIServer(config *PingerConfig, chat bread.ChatClient) (PingerServer, error) {
	return &apiServer{config, chat}, nil
}
