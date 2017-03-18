// Code generated by protoc-gen-go.
// source: ping.proto
// DO NOT EDIT!

package breadpb

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"
import operator "github.com/sr/operator"
import google_protobuf2 "github.com/golang/protobuf/ptypes/empty"

import (
	context "golang.org/x/net/context"
	grpc "google.golang.org/grpc"
)

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

type PingRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
}

func (m *PingRequest) Reset()                    { *m = PingRequest{} }
func (m *PingRequest) String() string            { return proto.CompactTextString(m) }
func (*PingRequest) ProtoMessage()               {}
func (*PingRequest) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{0} }

func (m *PingRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

type SlowLorisRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
	Wait    string            `protobuf:"bytes,2,opt,name=wait" json:"wait,omitempty"`
}

func (m *SlowLorisRequest) Reset()                    { *m = SlowLorisRequest{} }
func (m *SlowLorisRequest) String() string            { return proto.CompactTextString(m) }
func (*SlowLorisRequest) ProtoMessage()               {}
func (*SlowLorisRequest) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{1} }

func (m *SlowLorisRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

func (m *SlowLorisRequest) GetWait() string {
	if m != nil {
		return m.Wait
	}
	return ""
}

func init() {
	proto.RegisterType((*PingRequest)(nil), "bread.PingRequest")
	proto.RegisterType((*SlowLorisRequest)(nil), "bread.SlowLorisRequest")
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion4

// Client API for Ping service

type PingClient interface {
	// Reply with the email of the authenticated user. Requires 2FA
	Ping(ctx context.Context, in *PingRequest, opts ...grpc.CallOption) (*operator.Response, error)
	// Trigger a slow request, for testing timeout handling
	SlowLoris(ctx context.Context, in *SlowLorisRequest, opts ...grpc.CallOption) (*operator.Response, error)
}

type pingClient struct {
	cc *grpc.ClientConn
}

func NewPingClient(cc *grpc.ClientConn) PingClient {
	return &pingClient{cc}
}

func (c *pingClient) Ping(ctx context.Context, in *PingRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/bread.Ping/Ping", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *pingClient) SlowLoris(ctx context.Context, in *SlowLorisRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/bread.Ping/SlowLoris", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for Ping service

type PingServer interface {
	// Reply with the email of the authenticated user. Requires 2FA
	Ping(context.Context, *PingRequest) (*operator.Response, error)
	// Trigger a slow request, for testing timeout handling
	SlowLoris(context.Context, *SlowLorisRequest) (*operator.Response, error)
}

func RegisterPingServer(s *grpc.Server, srv PingServer) {
	s.RegisterService(&_Ping_serviceDesc, srv)
}

func _Ping_Ping_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(PingRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PingServer).Ping(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Ping/Ping",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PingServer).Ping(ctx, req.(*PingRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Ping_SlowLoris_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(SlowLorisRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PingServer).SlowLoris(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Ping/SlowLoris",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PingServer).SlowLoris(ctx, req.(*SlowLorisRequest))
	}
	return interceptor(ctx, in, info, handler)
}

var _Ping_serviceDesc = grpc.ServiceDesc{
	ServiceName: "bread.Ping",
	HandlerType: (*PingServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Ping",
			Handler:    _Ping_Ping_Handler,
		},
		{
			MethodName: "SlowLoris",
			Handler:    _Ping_SlowLoris_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "ping.proto",
}

// Client API for Pinger service

type PingerClient interface {
	Ping(ctx context.Context, in *google_protobuf2.Empty, opts ...grpc.CallOption) (*google_protobuf2.Empty, error)
}

type pingerClient struct {
	cc *grpc.ClientConn
}

func NewPingerClient(cc *grpc.ClientConn) PingerClient {
	return &pingerClient{cc}
}

func (c *pingerClient) Ping(ctx context.Context, in *google_protobuf2.Empty, opts ...grpc.CallOption) (*google_protobuf2.Empty, error) {
	out := new(google_protobuf2.Empty)
	err := grpc.Invoke(ctx, "/bread.Pinger/Ping", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for Pinger service

type PingerServer interface {
	Ping(context.Context, *google_protobuf2.Empty) (*google_protobuf2.Empty, error)
}

func RegisterPingerServer(s *grpc.Server, srv PingerServer) {
	s.RegisterService(&_Pinger_serviceDesc, srv)
}

func _Pinger_Ping_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(google_protobuf2.Empty)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PingerServer).Ping(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Pinger/Ping",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PingerServer).Ping(ctx, req.(*google_protobuf2.Empty))
	}
	return interceptor(ctx, in, info, handler)
}

var _Pinger_serviceDesc = grpc.ServiceDesc{
	ServiceName: "bread.Pinger",
	HandlerType: (*PingerServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Ping",
			Handler:    _Pinger_Ping_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "ping.proto",
}

func init() { proto.RegisterFile("ping.proto", fileDescriptor3) }

var fileDescriptor3 = []byte{
	// 251 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0xe2, 0xe2, 0x2a, 0xc8, 0xcc, 0x4b,
	0xd7, 0x2b, 0x28, 0xca, 0x2f, 0xc9, 0x17, 0x62, 0x4d, 0x2a, 0x4a, 0x4d, 0x4c, 0x91, 0x52, 0x4d,
	0xcf, 0x2c, 0xc9, 0x28, 0x4d, 0xd2, 0x4b, 0xce, 0xcf, 0xd5, 0x2f, 0x2e, 0xd2, 0xcf, 0x2f, 0x48,
	0x2d, 0x4a, 0x2c, 0xc9, 0x47, 0x30, 0x20, 0xaa, 0xa5, 0xa4, 0xd3, 0xf3, 0xf3, 0xd3, 0x73, 0x52,
	0xf5, 0xc1, 0xbc, 0xa4, 0xd2, 0x34, 0xfd, 0xd4, 0xdc, 0x82, 0x92, 0x4a, 0x88, 0xa4, 0x92, 0x15,
	0x17, 0x77, 0x40, 0x66, 0x5e, 0x7a, 0x50, 0x6a, 0x61, 0x69, 0x6a, 0x71, 0x89, 0x90, 0x36, 0x17,
	0x7b, 0x11, 0x84, 0x29, 0xc1, 0xa8, 0xc0, 0xa8, 0xc1, 0x6d, 0x24, 0xa8, 0x07, 0x37, 0x0d, 0xaa,
	0x26, 0x08, 0xa6, 0x42, 0x29, 0x98, 0x4b, 0x20, 0x38, 0x27, 0xbf, 0xdc, 0x27, 0xbf, 0x28, 0xb3,
	0x98, 0x1c, 0x03, 0x84, 0x84, 0xb8, 0x58, 0xca, 0x13, 0x33, 0x4b, 0x24, 0x98, 0x14, 0x18, 0x35,
	0x38, 0x83, 0xc0, 0x6c, 0xa3, 0x32, 0x2e, 0x16, 0x90, 0x83, 0x84, 0xf4, 0xa0, 0xb4, 0x90, 0x1e,
	0xd8, 0xb3, 0x7a, 0x48, 0xae, 0x94, 0x12, 0x42, 0x36, 0xb3, 0xb8, 0x20, 0x3f, 0xaf, 0x38, 0x55,
	0xc8, 0x82, 0x8b, 0x13, 0xee, 0x18, 0x21, 0x71, 0xa8, 0x26, 0x74, 0xe7, 0x61, 0xd3, 0x29, 0xc5,
	0x32, 0xa3, 0x49, 0x92, 0xd1, 0xc8, 0x81, 0x8b, 0x0d, 0x64, 0x45, 0x6a, 0x91, 0x90, 0x19, 0xd4,
	0x66, 0x31, 0x3d, 0x48, 0xc0, 0xe9, 0xc1, 0x02, 0x4e, 0xcf, 0x15, 0x14, 0x70, 0x52, 0x38, 0xc4,
	0x9d, 0x38, 0xa3, 0xd8, 0xc1, 0xb6, 0x16, 0x24, 0x25, 0xb1, 0x81, 0xa5, 0x8c, 0x01, 0x01, 0x00,
	0x00, 0xff, 0xff, 0xa4, 0x47, 0xce, 0xe0, 0xb5, 0x01, 0x00, 0x00,
}
