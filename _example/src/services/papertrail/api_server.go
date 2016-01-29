package papertrail

import (
	"bytes"
	"fmt"

	"github.com/sr/operator"

	papertrailapi "github.com/sourcegraph/go-papertrail/papertrail"
	"golang.org/x/net/context"
)

type apiServer struct {
	client *papertrailapi.Client
}

func newAPIServer(client *papertrailapi.Client) *apiServer {
	return &apiServer{client}
}

func (s *apiServer) Search(
	ctx context.Context,
	request *SearchRequest,
) (*SearchResponse, error) {
	if request.Query == "" {
		return nil, operator.NewArgumentRequiredError("Query")
	}
	options := papertrailapi.SearchOptions{
		Query: request.Query,
	}
	response, _, err := s.client.Search(options)
	if err != nil {
		return nil, fmt.Errorf("failed to execute search query: %v", err)
	}
	var logEvents []*LogEvent
	output := bytes.NewBufferString("")
	for _, event := range response.Events {
		logEvent := &LogEvent{
			Id:         event.ID,
			Source:     event.SourceName,
			Program:    *event.Program,
			LogMessage: event.Message,
		}
		logEvents = append(logEvents, logEvent)
		fmt.Fprintln(output, logEvent.LogMessage)
	}
	return &SearchResponse{
		Objects: logEvents,
		Output:  &operator.Output{PlainText: output.String()},
	}, nil
}
