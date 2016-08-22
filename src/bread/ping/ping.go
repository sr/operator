package breadping

import "github.com/sr/operator"

func NewAPIServer(replier operator.Replier, config *PingerConfig) (PingerServer, error) {
	return &apiServer{replier, config}, nil
}
