// Code generated by protoc-gen-go.
// source: ping.proto
// DO NOT EDIT!

package breadpb

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"
import operator "github.com/sr/operator"

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

func init() { proto.RegisterFile("ping.proto", fileDescriptor3) }

var fileDescriptor3 = []byte{
	// 202 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0xe2, 0xe2, 0x2a, 0xc8, 0xcc, 0x4b,
	0xd7, 0x2b, 0x28, 0xca, 0x2f, 0xc9, 0x17, 0x62, 0x4d, 0x2a, 0x4a, 0x4d, 0x4c, 0x91, 0x52, 0x4d,
	0xcf, 0x2c, 0xc9, 0x28, 0x4d, 0xd2, 0x4b, 0xce, 0xcf, 0xd5, 0x2f, 0x2e, 0xd2, 0xcf, 0x2f, 0x48,
	0x2d, 0x4a, 0x2c, 0xc9, 0x47, 0x30, 0x20, 0xaa, 0x95, 0xac, 0xb8, 0xb8, 0x03, 0x32, 0xf3, 0xd2,
	0x83, 0x52, 0x0b, 0x4b, 0x53, 0x8b, 0x4b, 0x84, 0xb4, 0xb9, 0xd8, 0x8b, 0x20, 0x4c, 0x09, 0x46,
	0x05, 0x46, 0x0d, 0x6e, 0x23, 0x41, 0x3d, 0xb8, 0x06, 0xa8, 0x9a, 0x20, 0x98, 0x0a, 0xa5, 0x60,
	0x2e, 0x81, 0xe0, 0x9c, 0xfc, 0x72, 0x9f, 0xfc, 0xa2, 0xcc, 0x62, 0x72, 0x0c, 0x10, 0x12, 0xe2,
	0x62, 0x29, 0x4f, 0xcc, 0x2c, 0x91, 0x60, 0x52, 0x60, 0xd4, 0xe0, 0x0c, 0x02, 0xb3, 0x8d, 0xca,
	0xb8, 0x58, 0x40, 0x0e, 0x12, 0xd2, 0x83, 0xd2, 0x42, 0x7a, 0x60, 0xff, 0xe8, 0x21, 0xb9, 0x52,
	0x4a, 0x08, 0xd9, 0xcc, 0xe2, 0x82, 0xfc, 0xbc, 0xe2, 0x54, 0x21, 0x0b, 0x2e, 0x4e, 0xb8, 0x63,
	0x84, 0xc4, 0xa1, 0x9a, 0xd0, 0x9d, 0x87, 0x4d, 0xa7, 0x14, 0xcb, 0x8c, 0x26, 0x49, 0x46, 0x27,
	0xce, 0x28, 0x76, 0xb0, 0x9e, 0x82, 0xa4, 0x24, 0x36, 0x70, 0xd0, 0x18, 0x03, 0x02, 0x00, 0x00,
	0xff, 0xff, 0x16, 0x6c, 0x37, 0x9f, 0x56, 0x01, 0x00, 0x00,
}
