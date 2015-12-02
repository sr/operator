package papertrail

import "golang.org/x/net/context"

type apiServer struct{}

func newAPIServer() *apiServer {
	return &apiServer{}
}

func (s *apiServer) Search(
	ctx context.Context,
	request *SearchRequest,
) (*SearchResponse, error) {
	var logEvents []*LogEvent
	return &SearchResponse{
		LogEvents: logEvents,
	}, nil
}
