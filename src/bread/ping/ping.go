package breadping

func NewAPIServer(config *PingerConfig) (PingerServer, error) {
	return &apiServer{config}, nil
}
