package operatorhipchat

import (
	"net/http"

	"github.com/sr/operator"
)

type requestDecoder struct{}

func NewRequestDecoder() *requestDecoder {
	return &requestDecoder{}
}

func (d *requestDecoder) Decode(req *http.Request) (*operator.Request, error) {
	// TODO(sr) Verify JWT signature of the request
	return nil, nil
}
