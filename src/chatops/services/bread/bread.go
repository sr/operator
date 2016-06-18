package bread

func NewAPIServer(config *BreadConfig) (BreadServer, error) {
	return newAPIServer(config)
}
