package openflights

import (
	"go.pedge.io/pb/go/google/protobuf"
	"golang.org/x/net/context"
)

var (
	emptyInstance = &google_protobuf.Empty{}
)

type apiServer struct {
	client Client
}

func newAPIServer(client Client) *apiServer {
	return &apiServer{client}
}

func (a *apiServer) GetAllAirports(request *google_protobuf.Empty, server API_GetAllAirportsServer) error {
	out, cancel, callbackErr, err := a.client.GetAllAirports()
	if err != nil {
		return err
	}
	for {
		select {
		case value := <-out:
			if value == nil {
				close(cancel)
				return <-callbackErr
			}
			if err := server.Send(value); err != nil {
				close(cancel)
				<-callbackErr
				return err
			}
		case <-server.Context().Done():
			close(cancel)
			if err := <-callbackErr; err != nil {
				return err
			}
			return server.Context().Err()
		}
	}
}

func (a *apiServer) GetAllAirlines(request *google_protobuf.Empty, server API_GetAllAirlinesServer) error {
	out, cancel, callbackErr, err := a.client.GetAllAirlines()
	if err != nil {
		return err
	}
	for {
		select {
		case value := <-out:
			if value == nil {
				close(cancel)
				return <-callbackErr
			}
			if err := server.Send(value); err != nil {
				close(cancel)
				<-callbackErr
				return err
			}
		case <-server.Context().Done():
			close(cancel)
			if err := <-callbackErr; err != nil {
				return err
			}
			return server.Context().Err()
		}
	}
}

func (a *apiServer) GetAllRoutes(request *google_protobuf.Empty, server API_GetAllRoutesServer) error {
	out, cancel, callbackErr, err := a.client.GetAllRoutes()
	if err != nil {
		return err
	}
	for {
		select {
		case value := <-out:
			if value == nil {
				close(cancel)
				return <-callbackErr
			}
			if err := server.Send(value); err != nil {
				close(cancel)
				<-callbackErr
				return err
			}
		case <-server.Context().Done():
			close(cancel)
			if err := <-callbackErr; err != nil {
				return err
			}
			return server.Context().Err()
		}
	}
}

func (a *apiServer) GetAirport(_ context.Context, request *GetAirportRequest) (response *Airport, err error) {
	return a.client.GetAirport(request.Id)
}

func (a *apiServer) GetAirline(_ context.Context, request *GetAirlineRequest) (response *Airline, err error) {
	return a.client.GetAirline(request.Id)
}

func (a *apiServer) GetRoutes(_ context.Context, request *GetRoutesRequest) (response *Routes, err error) {
	routes, err := a.client.GetRoutes(request.AirlineId, request.SourceAirportId, request.DestinationAirportId)
	if err != nil {
		return nil, err
	}
	return &Routes{
		Route: routes,
	}, nil
}

func (a *apiServer) GetDistance(_ context.Context, request *GetDistanceRequest) (response *google_protobuf.UInt32Value, err error) {
	distance, err := a.client.GetDistance(request.SourceAirportId, request.DestinationAirportId)
	if err != nil {
		return nil, err
	}
	return &google_protobuf.UInt32Value{
		Value: distance,
	}, nil
}

func (a *apiServer) GetMiles(_ context.Context, request *GetMilesRequest) (response *GetMilesResponse, err error) {
	return a.client.GetMiles(request)
}
