// Code generated by protoc-gen-go.
// source: pb/ping.proto
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

type OtpRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
}

func (m *OtpRequest) Reset()                    { *m = OtpRequest{} }
func (m *OtpRequest) String() string            { return proto.CompactTextString(m) }
func (*OtpRequest) ProtoMessage()               {}
func (*OtpRequest) Descriptor() ([]byte, []int) { return fileDescriptor2, []int{0} }

func (m *OtpRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

type PingRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
	Arg1    string            `protobuf:"bytes,2,opt,name=arg1" json:"arg1,omitempty"`
}

func (m *PingRequest) Reset()                    { *m = PingRequest{} }
func (m *PingRequest) String() string            { return proto.CompactTextString(m) }
func (*PingRequest) ProtoMessage()               {}
func (*PingRequest) Descriptor() ([]byte, []int) { return fileDescriptor2, []int{1} }

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
func (*SlowLorisRequest) Descriptor() ([]byte, []int) { return fileDescriptor2, []int{2} }

func (m *SlowLorisRequest) GetRequest() *operator.Request {
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
func (*WhoamiRequest) Descriptor() ([]byte, []int) { return fileDescriptor2, []int{3} }

func (m *WhoamiRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

func init() {
	proto.RegisterType((*OtpRequest)(nil), "bread.OtpRequest")
	proto.RegisterType((*PingRequest)(nil), "bread.PingRequest")
	proto.RegisterType((*SlowLorisRequest)(nil), "bread.SlowLorisRequest")
	proto.RegisterType((*WhoamiRequest)(nil), "bread.WhoamiRequest")
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion3

// Client API for Ping service

type PingClient interface {
	Otp(ctx context.Context, in *OtpRequest, opts ...grpc.CallOption) (*operator.Response, error)
	Ping(ctx context.Context, in *PingRequest, opts ...grpc.CallOption) (*operator.Response, error)
	SlowLoris(ctx context.Context, in *SlowLorisRequest, opts ...grpc.CallOption) (*operator.Response, error)
	Whoami(ctx context.Context, in *WhoamiRequest, opts ...grpc.CallOption) (*operator.Response, error)
}

type pingClient struct {
	cc *grpc.ClientConn
}

func NewPingClient(cc *grpc.ClientConn) PingClient {
	return &pingClient{cc}
}

func (c *pingClient) Otp(ctx context.Context, in *OtpRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/bread.Ping/Otp", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
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

func (c *pingClient) Whoami(ctx context.Context, in *WhoamiRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/bread.Ping/Whoami", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for Ping service

type PingServer interface {
	Otp(context.Context, *OtpRequest) (*operator.Response, error)
	Ping(context.Context, *PingRequest) (*operator.Response, error)
	SlowLoris(context.Context, *SlowLorisRequest) (*operator.Response, error)
	Whoami(context.Context, *WhoamiRequest) (*operator.Response, error)
}

func RegisterPingServer(s *grpc.Server, srv PingServer) {
	s.RegisterService(&_Ping_serviceDesc, srv)
}

func _Ping_Otp_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(OtpRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PingServer).Otp(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Ping/Otp",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PingServer).Otp(ctx, req.(*OtpRequest))
	}
	return interceptor(ctx, in, info, handler)
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

func _Ping_Whoami_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(WhoamiRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PingServer).Whoami(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Ping/Whoami",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PingServer).Whoami(ctx, req.(*WhoamiRequest))
	}
	return interceptor(ctx, in, info, handler)
}

var _Ping_serviceDesc = grpc.ServiceDesc{
	ServiceName: "bread.Ping",
	HandlerType: (*PingServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Otp",
			Handler:    _Ping_Otp_Handler,
		},
		{
			MethodName: "Ping",
			Handler:    _Ping_Ping_Handler,
		},
		{
			MethodName: "SlowLoris",
			Handler:    _Ping_SlowLoris_Handler,
		},
		{
			MethodName: "Whoami",
			Handler:    _Ping_Whoami_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: fileDescriptor2,
}

func init() { proto.RegisterFile("pb/ping.proto", fileDescriptor2) }

var fileDescriptor2 = []byte{
	// 244 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0xe2, 0xe2, 0x2d, 0x48, 0xd2, 0x2f,
	0xc8, 0xcc, 0x4b, 0xd7, 0x2b, 0x28, 0xca, 0x2f, 0xc9, 0x17, 0x62, 0x4d, 0x2a, 0x4a, 0x4d, 0x4c,
	0x91, 0xe2, 0xcb, 0x2f, 0x48, 0x2d, 0x4a, 0x2c, 0xc9, 0x2f, 0x82, 0x08, 0x2b, 0x59, 0x72, 0x71,
	0xf9, 0x97, 0x14, 0x04, 0xa5, 0x16, 0x96, 0xa6, 0x16, 0x97, 0x08, 0x69, 0x73, 0xb1, 0x17, 0x41,
	0x98, 0x12, 0x8c, 0x0a, 0x8c, 0x1a, 0xdc, 0x46, 0x82, 0x7a, 0x70, 0xf5, 0x50, 0x35, 0x41, 0x30,
	0x15, 0x4a, 0x7e, 0x5c, 0xdc, 0x01, 0x99, 0x79, 0xe9, 0xe4, 0xe8, 0x15, 0x12, 0xe2, 0x62, 0x49,
	0x2c, 0x4a, 0x37, 0x94, 0x60, 0x52, 0x60, 0xd4, 0xe0, 0x0c, 0x02, 0xb3, 0x95, 0x82, 0xb9, 0x04,
	0x82, 0x73, 0xf2, 0xcb, 0x7d, 0xf2, 0x8b, 0x32, 0x8b, 0xc9, 0x35, 0xb4, 0x3c, 0x31, 0xb3, 0x04,
	0x66, 0x28, 0x88, 0xad, 0x64, 0xc3, 0xc5, 0x1b, 0x9e, 0x91, 0x9f, 0x98, 0x9b, 0x49, 0x8e, 0x89,
	0x46, 0x97, 0x18, 0xb9, 0x58, 0x40, 0x7e, 0x14, 0xd2, 0xe1, 0x62, 0xf6, 0x2f, 0x29, 0x10, 0x12,
	0xd4, 0x03, 0x87, 0xa2, 0x1e, 0x22, 0xc8, 0xa4, 0x84, 0x90, 0xb5, 0x17, 0x17, 0xe4, 0xe7, 0x15,
	0xa7, 0x0a, 0xe9, 0x41, 0x75, 0x09, 0x41, 0x95, 0x23, 0x05, 0x13, 0x56, 0xf5, 0x16, 0x5c, 0x9c,
	0x70, 0x9f, 0x0b, 0x89, 0x43, 0x35, 0xa1, 0x87, 0x05, 0x56, 0x9d, 0x46, 0x5c, 0x6c, 0x10, 0xef,
	0x09, 0x89, 0x40, 0xb5, 0xa1, 0xf8, 0x16, 0x9b, 0x1e, 0x27, 0xce, 0x28, 0x76, 0xb0, 0xd2, 0x82,
	0xa4, 0x24, 0x36, 0x70, 0x22, 0x30, 0x06, 0x04, 0x00, 0x00, 0xff, 0xff, 0x2e, 0xfe, 0xba, 0xb3,
	0x2c, 0x02, 0x00, 0x00,
}
