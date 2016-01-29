package openflights

import (
	"time"

	"go.pedge.io/pb/go/google/protobuf"
	"go.pedge.io/proto/rpclog"
	"golang.org/x/net/context"
)

type logAPIServer struct {
	protorpclog.Logger
	delegate APIServer
}

func newLogAPIServer(delegate APIServer) *logAPIServer {
	return &logAPIServer{protorpclog.NewLogger("openflights.API"), delegate}
}

func (a *logAPIServer) GetAllAirports(request *google_protobuf.Empty, server API_GetAllAirportsServer) (err error) {
	defer func(start time.Time) { a.Log(request, nil, err, time.Since(start)) }(time.Now())
	return a.delegate.GetAllAirports(request, server)
}

func (a *logAPIServer) GetAllAirlines(request *google_protobuf.Empty, server API_GetAllAirlinesServer) (err error) {
	defer func(start time.Time) { a.Log(request, nil, err, time.Since(start)) }(time.Now())
	return a.delegate.GetAllAirlines(request, server)
}

func (a *logAPIServer) GetAllRoutes(request *google_protobuf.Empty, server API_GetAllRoutesServer) (err error) {
	defer func(start time.Time) { a.Log(request, nil, err, time.Since(start)) }(time.Now())
	return a.delegate.GetAllRoutes(request, server)
}

func (a *logAPIServer) GetAirport(ctx context.Context, request *GetAirportRequest) (response *Airport, err error) {
	defer func(start time.Time) { a.Log(request, response, err, time.Since(start)) }(time.Now())
	return a.delegate.GetAirport(ctx, request)
}

func (a *logAPIServer) GetAirline(ctx context.Context, request *GetAirlineRequest) (response *Airline, err error) {
	defer func(start time.Time) { a.Log(request, response, err, time.Since(start)) }(time.Now())
	return a.delegate.GetAirline(ctx, request)
}

func (a *logAPIServer) GetRoutes(ctx context.Context, request *GetRoutesRequest) (response *Routes, err error) {
	defer func(start time.Time) { a.Log(request, response, err, time.Since(start)) }(time.Now())
	return a.delegate.GetRoutes(ctx, request)
}

func (a *logAPIServer) GetDistance(ctx context.Context, request *GetDistanceRequest) (response *google_protobuf.UInt32Value, err error) {
	defer func(start time.Time) { a.Log(request, response, err, time.Since(start)) }(time.Now())
	return a.delegate.GetDistance(ctx, request)
}

func (a *logAPIServer) GetMiles(ctx context.Context, request *GetMilesRequest) (response *GetMilesResponse, err error) {
	defer func(start time.Time) { a.Log(request, response, err, time.Since(start)) }(time.Now())
	return a.delegate.GetMiles(ctx, request)
}
