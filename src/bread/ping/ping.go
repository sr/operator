package breadping

import "bread"

func NewAPIServer(config *PingerConfig) (PingerServer, error) {
	c, err := bread.NewHipchatClient("")
	if err != nil {
		return nil, err
	}
	return &apiServer{config, c}, err
}
