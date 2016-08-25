// Code generated by protoc-gen-go.
// source: ping/ping.proto
// DO NOT EDIT!

/*
Package breadping is a generated protocol buffer package.

It is generated from these files:
	ping/ping.proto

It has these top-level messages:
	PingerConfig
	PingRequest
	WhoamiRequest
*/
package breadping

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

// This is a compile-time assertion to ensure that this generated file
// is compatible with the proto package it is being compiled against.
// A compilation error at this line likely means your copy of the
// proto package needs to be updated.
const _ = proto.ProtoPackageIsVersion2 // please upgrade the proto package

type PingerConfig struct {
}

func (m *PingerConfig) Reset()                    { *m = PingerConfig{} }
func (m *PingerConfig) String() string            { return proto.CompactTextString(m) }
func (*PingerConfig) ProtoMessage()               {}
func (*PingerConfig) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

type PingRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
	Arg1    string            `protobuf:"bytes,2,opt,name=arg1" json:"arg1,omitempty"`
}

func (m *PingRequest) Reset()                    { *m = PingRequest{} }
func (m *PingRequest) String() string            { return proto.CompactTextString(m) }
func (*PingRequest) ProtoMessage()               {}
func (*PingRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

func (m *PingRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

type WhoamiRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
}

func (m *WhoamiRequest) Reset()                    { *m = WhoamiRequest{} }
func (m *WhoamiRequest) String() string            { return proto.CompactTextString(m) }
func (*WhoamiRequest) ProtoMessage()               {}
func (*WhoamiRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{2} }

func (m *WhoamiRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

func init() {
	proto.RegisterType((*PingerConfig)(nil), "ping.PingerConfig")
	proto.RegisterType((*PingRequest)(nil), "ping.PingRequest")
	proto.RegisterType((*WhoamiRequest)(nil), "ping.WhoamiRequest")
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion3

// Client API for Pinger service

type PingerClient interface {
	Ping(ctx context.Context, in *PingRequest, opts ...grpc.CallOption) (*operator.Response, error)
	Whoami(ctx context.Context, in *WhoamiRequest, opts ...grpc.CallOption) (*operator.Response, error)
}

type pingerClient struct {
	cc *grpc.ClientConn
}

func NewPingerClient(cc *grpc.ClientConn) PingerClient {
	return &pingerClient{cc}
}

func (c *pingerClient) Ping(ctx context.Context, in *PingRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/ping.Pinger/Ping", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *pingerClient) Whoami(ctx context.Context, in *WhoamiRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/ping.Pinger/Whoami", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for Pinger service

type PingerServer interface {
	Ping(context.Context, *PingRequest) (*operator.Response, error)
	Whoami(context.Context, *WhoamiRequest) (*operator.Response, error)
}

func RegisterPingerServer(s *grpc.Server, srv PingerServer) {
	s.RegisterService(&_Pinger_serviceDesc, srv)
}

func _Pinger_Ping_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(PingRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PingerServer).Ping(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ping.Pinger/Ping",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PingerServer).Ping(ctx, req.(*PingRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Pinger_Whoami_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(WhoamiRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PingerServer).Whoami(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/ping.Pinger/Whoami",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PingerServer).Whoami(ctx, req.(*WhoamiRequest))
	}
	return interceptor(ctx, in, info, handler)
}

var _Pinger_serviceDesc = grpc.ServiceDesc{
	ServiceName: "ping.Pinger",
	HandlerType: (*PingerServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Ping",
			Handler:    _Pinger_Ping_Handler,
		},
		{
			MethodName: "Whoami",
			Handler:    _Pinger_Whoami_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: fileDescriptor0,
}

func init() { proto.RegisterFile("ping/ping.proto", fileDescriptor0) }

var fileDescriptor0 = []byte{
	// 203 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0xe2, 0xe2, 0x2f, 0xc8, 0xcc, 0x4b,
	0xd7, 0x07, 0x11, 0x7a, 0x05, 0x45, 0xf9, 0x25, 0xf9, 0x42, 0x2c, 0x20, 0xb6, 0x14, 0x5f, 0x7e,
	0x41, 0x6a, 0x51, 0x62, 0x49, 0x7e, 0x11, 0x44, 0x54, 0x89, 0x8f, 0x8b, 0x27, 0x20, 0x33, 0x2f,
	0x3d, 0xb5, 0xc8, 0x39, 0x3f, 0x2f, 0x2d, 0x33, 0x5d, 0xc9, 0x8f, 0x8b, 0x1b, 0xc4, 0x0f, 0x4a,
	0x2d, 0x2c, 0x4d, 0x2d, 0x2e, 0x11, 0xd2, 0xe6, 0x62, 0x2f, 0x82, 0x30, 0x25, 0x18, 0x15, 0x18,
	0x35, 0xb8, 0x8d, 0x04, 0xf5, 0xe0, 0x06, 0x40, 0xd5, 0x04, 0xc1, 0x54, 0x08, 0x09, 0x71, 0xb1,
	0x24, 0x16, 0xa5, 0x1b, 0x4a, 0x30, 0x29, 0x30, 0x6a, 0x70, 0x06, 0x81, 0xd9, 0x4a, 0x36, 0x5c,
	0xbc, 0xe1, 0x19, 0xf9, 0x89, 0xb9, 0x99, 0xe4, 0x98, 0x68, 0x54, 0xc2, 0xc5, 0x06, 0x71, 0x9d,
	0x90, 0x2e, 0x17, 0x0b, 0x88, 0x25, 0x24, 0xa8, 0x07, 0xf6, 0x12, 0x92, 0x1b, 0xa5, 0x84, 0x90,
	0x0d, 0x28, 0x2e, 0xc8, 0xcf, 0x2b, 0x4e, 0x15, 0x32, 0xe4, 0x62, 0x83, 0x58, 0x2b, 0x24, 0x0c,
	0xd1, 0x80, 0xe2, 0x08, 0x6c, 0x5a, 0xa4, 0x38, 0x26, 0x35, 0x49, 0x82, 0xc3, 0xc8, 0x89, 0x3b,
	0x8a, 0x33, 0xa9, 0x28, 0x35, 0x31, 0x05, 0xc4, 0x49, 0x62, 0x03, 0x87, 0x93, 0x31, 0x20, 0x00,
	0x00, 0xff, 0xff, 0x39, 0xf8, 0x08, 0xc5, 0x50, 0x01, 0x00, 0x00,
}
