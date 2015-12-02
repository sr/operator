package papertrail

import (
	gopapertrail "github.com/sourcegraph/go-papertrail/papertrail"
	"golang.org/x/net/context"
)

type apiServer struct {
	client *gopapertrail.Client
}

func newAPIServer(client *gopapertrail.Client) *apiServer {
	return &apiServer{client}
}

func (s *apiServer) Search(
	ctx context.Context,
	request *SearchRequest,
) (*SearchResponse, error) {
	options := gopapertrail.SearchOptions{
		Query: request.Query,
	}
	response, _, err := s.client.Search(options)
	if err != nil {
		return nil, err
	}

	var logEvents []*LogEvent
	for _, event := range response.Events {
		logEvents = append(logEvents, &LogEvent{
			Id:         event.ID,
			Source:     event.SourceName,
			Program:    *event.Program,
			LogMessage: event.Message,
		})
	}

	return &SearchResponse{
		LogEvents: logEvents,
	}, nil
}
