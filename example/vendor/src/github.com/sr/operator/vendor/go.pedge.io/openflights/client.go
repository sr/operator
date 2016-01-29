package openflights

import (
	"io"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"

	"go.pedge.io/pb/go/google/protobuf"
	"golang.org/x/net/context"
)

type client struct {
	apiClient APIClient
}

func newClient(apiClient APIClient) *client {
	return &client{
		apiClient,
	}
}

func (c *client) GetAllAirports() (<-chan *Airport, chan<- bool, <-chan error, error) {
	out := make(chan *Airport)
	cancel := make(chan bool, 1)
	callbackErr := make(chan error, 1)
	ctx, ctxCancel := context.WithCancel(context.Background())
	client, err := c.apiClient.GetAllAirports(ctx, google_protobuf.EmptyInstance)
	if err != nil {
		return nil, nil, nil, err
	}
	go func() {
		defer close(out)
		defer close(callbackErr)
		for airport, err := client.Recv(); err != io.EOF; airport, err = client.Recv() {
			if err != nil {
				callbackErr <- err
				return
			}
			select {
			case out <- airport:
			case <-cancel:
				ctxCancel()
				<-ctx.Done()
				callbackErr <- ctx.Err()
				return
			}
		}
		callbackErr <- nil
	}()
	return out, cancel, callbackErr, nil
}

func (c *client) GetAllAirlines() (<-chan *Airline, chan<- bool, <-chan error, error) {
	out := make(chan *Airline)
	cancel := make(chan bool, 1)
	callbackErr := make(chan error, 1)
	ctx, ctxCancel := context.WithCancel(context.Background())
	client, err := c.apiClient.GetAllAirlines(ctx, google_protobuf.EmptyInstance)
	if err != nil {
		return nil, nil, nil, err
	}
	go func() {
		defer close(out)
		defer close(callbackErr)
		for airline, err := client.Recv(); err != io.EOF; airline, err = client.Recv() {
			if err != nil {
				callbackErr <- err
				return
			}
			select {
			case out <- airline:
			case <-cancel:
				ctxCancel()
				<-ctx.Done()
				callbackErr <- ctx.Err()
				return
			}
		}
		callbackErr <- nil
	}()
	return out, cancel, callbackErr, nil
}

func (c *client) GetAllRoutes() (<-chan *Route, chan<- bool, <-chan error, error) {
	out := make(chan *Route)
	cancel := make(chan bool, 1)
	callbackErr := make(chan error, 1)
	ctx, ctxCancel := context.WithCancel(context.Background())
	client, err := c.apiClient.GetAllRoutes(ctx, google_protobuf.EmptyInstance)
	if err != nil {
		return nil, nil, nil, err
	}
	go func() {
		defer close(out)
		defer close(callbackErr)
		for route, err := client.Recv(); err != io.EOF; route, err = client.Recv() {
			if err != nil {
				callbackErr <- err
				return
			}
			select {
			case out <- route:
			case <-cancel:
				ctxCancel()
				<-ctx.Done()
				callbackErr <- ctx.Err()
				return
			}
		}
		callbackErr <- nil
	}()
	return out, cancel, callbackErr, nil
}

func (c *client) GetAirportByID(id string) (*Airport, error) {
	airport, err := c.GetAirport(id)
	if err != nil {
		return nil, err
	}
	if airport.Id != id {
		return nil, grpc.Errorf(codes.NotFound, id)
	}
	return airport, nil
}

func (c *client) GetAirlineByID(id string) (*Airline, error) {
	airline, err := c.GetAirline(id)
	if err != nil {
		return nil, err
	}
	if airline.Id != id {
		return nil, grpc.Errorf(codes.NotFound, id)
	}
	return airline, nil
}

func (c *client) GetAirportByCode(code string) (*Airport, error) {
	airport, err := c.GetAirport(code)
	if err != nil {
		return nil, err
	}
	if !containsString(airport.Codes(), code) {
		return nil, grpc.Errorf(codes.NotFound, code)
	}
	return airport, nil
}

func (c *client) GetAirlineByCode(code string) (*Airline, error) {
	airline, err := c.GetAirline(code)
	if err != nil {
		return nil, err
	}
	if !containsString(airline.Codes(), code) {
		return nil, grpc.Errorf(codes.NotFound, code)
	}
	return airline, nil
}

func (c *client) GetRoutes(airlineIDOrCode string, sourceAirportIDOrCode string, destinationAirportIDOrCode string) ([]*Route, error) {
	routes, err := c.apiClient.GetRoutes(
		context.Background(),
		&GetRoutesRequest{
			AirlineId:            airlineIDOrCode,
			SourceAirportId:      sourceAirportIDOrCode,
			DestinationAirportId: destinationAirportIDOrCode,
		},
	)
	if err != nil {
		return nil, err
	}
	return routes.Route, nil
}

func (c *client) GetAirport(idOrCode string) (*Airport, error) {
	return c.apiClient.GetAirport(
		context.Background(),
		&GetAirportRequest{
			Id: idOrCode,
		},
	)
}

func (c *client) GetAirline(idOrCode string) (*Airline, error) {
	return c.apiClient.GetAirline(
		context.Background(),
		&GetAirlineRequest{
			Id: idOrCode,
		},
	)
}

func (c *client) GetDistance(sourceAirportIDOrCode string, destinationAirportIDOrCode string) (uint32, error) {
	uint32Value, err := c.apiClient.GetDistance(
		context.Background(),
		&GetDistanceRequest{
			SourceAirportId:      sourceAirportIDOrCode,
			DestinationAirportId: destinationAirportIDOrCode,
		},
	)
	if err != nil {
		return 0, err
	}
	return uint32Value.Value, nil
}

func (c *client) GetMiles(request *GetMilesRequest) (*GetMilesResponse, error) {
	return c.apiClient.GetMiles(
		context.Background(),
		request,
	)
}
