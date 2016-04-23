package pinger

type Env struct {
}

func NewAPIServer(config *Env) (PingerServer, error) {
	return &apiServer{config}, nil
}
