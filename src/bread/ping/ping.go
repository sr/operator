package breadping

import "github.com/sr/operator"

func NewAPIServer(replier operator.Replier) (PingerServer, error) {
	return &apiServer{replier}, nil
}
