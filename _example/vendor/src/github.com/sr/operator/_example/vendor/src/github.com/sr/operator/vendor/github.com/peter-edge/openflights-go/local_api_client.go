package openflights

import (
	"io"

	"go.pedge.io/pb/go/google/protobuf"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

type localAPIClient struct {
	apiServer APIServer
}

func newLocalAPIClient(apiServer APIServer) *localAPIClient {
	return &localAPIClient{apiServer}
}

func (a *localAPIClient) GetAllAirports(ctx context.Context, request *google_protobuf.Empty, _ ...grpc.CallOption) (API_GetAllAirportsClient, error) {
	relayer := newLocalAPIGetAllAirportsRelayer(ctx)
	go func() {
		// TODO(pedge): what to do with the error?
		// if you actually trace the code, you'll find out that
		// it is not possible for there to be an error here because of the implementation,
		// but this is not how we code
		_ = a.apiServer.GetAllAirports(request, relayer)
		relayer.Close()
	}()
	return relayer, nil
}

type localAPIGetAllAirportsRelayer struct {
	ctx context.Context
	c   chan *Airport
}

func newLocalAPIGetAllAirportsRelayer(ctx context.Context) *localAPIGetAllAirportsRelayer {
	return &localAPIGetAllAirportsRelayer{ctx, make(chan *Airport)}
}

func (r *localAPIGetAllAirportsRelayer) Context() context.Context {
	return r.ctx
}

func (r *localAPIGetAllAirportsRelayer) Send(value *Airport) error {
	r.c <- value
	return nil
}

func (r *localAPIGetAllAirportsRelayer) Recv() (*Airport, error) {
	value := <-r.c
	if value == nil {
		return nil, io.EOF
	}
	return value, nil
}

func (r *localAPIGetAllAirportsRelayer) Close() {
	close(r.c)
}

func (r *localAPIGetAllAirportsRelayer) SendHeader(metadata.MD) error { return nil }
func (r *localAPIGetAllAirportsRelayer) SetTrailer(metadata.MD)       {}
func (r *localAPIGetAllAirportsRelayer) Header() (metadata.MD, error) { return nil, nil }
func (r *localAPIGetAllAirportsRelayer) Trailer() metadata.MD         { return nil }
func (r *localAPIGetAllAirportsRelayer) CloseSend() error             { return nil }
func (r *localAPIGetAllAirportsRelayer) SendMsg(m interface{}) error  { return nil }
func (r *localAPIGetAllAirportsRelayer) RecvMsg(m interface{}) error  { return nil }

func (a *localAPIClient) GetAllAirlines(ctx context.Context, request *google_protobuf.Empty, _ ...grpc.CallOption) (API_GetAllAirlinesClient, error) {
	relayer := newLocalAPIGetAllAirlinesRelayer(ctx)
	go func() {
		// TODO(pedge): what to do with the error?
		// if you actually trace the code, you'll find out that
		// it is not possible for there to be an error here because of the implementation,
		// but this is not how we code
		_ = a.apiServer.GetAllAirlines(request, relayer)
		relayer.Close()
	}()
	return relayer, nil
}

type localAPIGetAllAirlinesRelayer struct {
	ctx context.Context
	c   chan *Airline
}

func newLocalAPIGetAllAirlinesRelayer(ctx context.Context) *localAPIGetAllAirlinesRelayer {
	return &localAPIGetAllAirlinesRelayer{ctx, make(chan *Airline)}
}

func (r *localAPIGetAllAirlinesRelayer) Context() context.Context {
	return r.ctx
}

func (r *localAPIGetAllAirlinesRelayer) Send(value *Airline) error {
	r.c <- value
	return nil
}

func (r *localAPIGetAllAirlinesRelayer) Recv() (*Airline, error) {
	value := <-r.c
	if value == nil {
		return nil, io.EOF
	}
	return value, nil
}

func (r *localAPIGetAllAirlinesRelayer) Close() {
	close(r.c)
}

func (r *localAPIGetAllAirlinesRelayer) SendHeader(metadata.MD) error { return nil }
func (r *localAPIGetAllAirlinesRelayer) SetTrailer(metadata.MD)       {}
func (r *localAPIGetAllAirlinesRelayer) Header() (metadata.MD, error) { return nil, nil }
func (r *localAPIGetAllAirlinesRelayer) Trailer() metadata.MD         { return nil }
func (r *localAPIGetAllAirlinesRelayer) CloseSend() error             { return nil }
func (r *localAPIGetAllAirlinesRelayer) SendMsg(m interface{}) error  { return nil }
func (r *localAPIGetAllAirlinesRelayer) RecvMsg(m interface{}) error  { return nil }

func (a *localAPIClient) GetAllRoutes(ctx context.Context, request *google_protobuf.Empty, _ ...grpc.CallOption) (API_GetAllRoutesClient, error) {
	relayer := newLocalAPIGetAllRoutesRelayer(ctx)
	go func() {
		// TODO(pedge): what to do with the error?
		// if you actually trace the code, you'll find out that
		// it is not possible for there to be an error here because of the implementation,
		// but this is not how we code
		_ = a.apiServer.GetAllRoutes(request, relayer)
		relayer.Close()
	}()
	return relayer, nil
}

type localAPIGetAllRoutesRelayer struct {
	ctx context.Context
	c   chan *Route
}

func newLocalAPIGetAllRoutesRelayer(ctx context.Context) *localAPIGetAllRoutesRelayer {
	return &localAPIGetAllRoutesRelayer{ctx, make(chan *Route)}
}

func (r *localAPIGetAllRoutesRelayer) Context() context.Context {
	return r.ctx
}

func (r *localAPIGetAllRoutesRelayer) Send(value *Route) error {
	r.c <- value
	return nil
}

func (r *localAPIGetAllRoutesRelayer) Recv() (*Route, error) {
	value := <-r.c
	if value == nil {
		return nil, io.EOF
	}
	return value, nil
}

func (r *localAPIGetAllRoutesRelayer) Close() {
	close(r.c)
}

func (r *localAPIGetAllRoutesRelayer) SendHeader(metadata.MD) error { return nil }
func (r *localAPIGetAllRoutesRelayer) SetTrailer(metadata.MD)       {}
func (r *localAPIGetAllRoutesRelayer) Header() (metadata.MD, error) { return nil, nil }
func (r *localAPIGetAllRoutesRelayer) Trailer() metadata.MD         { return nil }
func (r *localAPIGetAllRoutesRelayer) CloseSend() error             { return nil }
func (r *localAPIGetAllRoutesRelayer) SendMsg(m interface{}) error  { return nil }
func (r *localAPIGetAllRoutesRelayer) RecvMsg(m interface{}) error  { return nil }

func (a *localAPIClient) GetAirport(ctx context.Context, request *GetAirportRequest, _ ...grpc.CallOption) (*Airport, error) {
	return a.apiServer.GetAirport(ctx, request)
}

func (a *localAPIClient) GetAirline(ctx context.Context, request *GetAirlineRequest, _ ...grpc.CallOption) (*Airline, error) {
	return a.apiServer.GetAirline(ctx, request)
}

func (a *localAPIClient) GetRoutes(ctx context.Context, request *GetRoutesRequest, _ ...grpc.CallOption) (*Routes, error) {
	return a.apiServer.GetRoutes(ctx, request)
}

func (a *localAPIClient) GetDistance(ctx context.Context, request *GetDistanceRequest, _ ...grpc.CallOption) (*google_protobuf.UInt32Value, error) {
	return a.apiServer.GetDistance(ctx, request)
}

func (a *localAPIClient) GetMiles(ctx context.Context, request *GetMilesRequest, _ ...grpc.CallOption) (*GetMilesResponse, error) {
	return a.apiServer.GetMiles(ctx, request)
}
