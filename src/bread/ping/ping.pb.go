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
	PingResponse
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
const _ = proto.ProtoPackageIsVersion1

type PingerConfig struct {
}

func (m *PingerConfig) Reset()                    { *m = PingerConfig{} }
func (m *PingerConfig) String() string            { return proto.CompactTextString(m) }
func (*PingerConfig) ProtoMessage()               {}
func (*PingerConfig) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

type PingRequest struct {
	Source *operator.Source `protobuf:"bytes,1,opt,name=source" json:"source,omitempty"`
	Arg1   string           `protobuf:"bytes,2,opt,name=arg1" json:"arg1,omitempty"`
}

func (m *PingRequest) Reset()                    { *m = PingRequest{} }
func (m *PingRequest) String() string            { return proto.CompactTextString(m) }
func (*PingRequest) ProtoMessage()               {}
func (*PingRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

func (m *PingRequest) GetSource() *operator.Source {
	if m != nil {
		return m.Source
	}
	return nil
}

type PingResponse struct {
	Output *operator.Output `protobuf:"bytes,1,opt,name=output" json:"output,omitempty"`
}

func (m *PingResponse) Reset()                    { *m = PingResponse{} }
func (m *PingResponse) String() string            { return proto.CompactTextString(m) }
func (*PingResponse) ProtoMessage()               {}
func (*PingResponse) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{2} }

func (m *PingResponse) GetOutput() *operator.Output {
	if m != nil {
		return m.Output
	}
	return nil
}

func init() {
	proto.RegisterType((*PingerConfig)(nil), "ping.PingerConfig")
	proto.RegisterType((*PingRequest)(nil), "ping.PingRequest")
	proto.RegisterType((*PingResponse)(nil), "ping.PingResponse")
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion2

// Client API for Pinger service

type PingerClient interface {
	Ping(ctx context.Context, in *PingRequest, opts ...grpc.CallOption) (*PingResponse, error)
}

type pingerClient struct {
	cc *grpc.ClientConn
}

func NewPingerClient(cc *grpc.ClientConn) PingerClient {
	return &pingerClient{cc}
}

func (c *pingerClient) Ping(ctx context.Context, in *PingRequest, opts ...grpc.CallOption) (*PingResponse, error) {
	out := new(PingResponse)
	err := grpc.Invoke(ctx, "/ping.Pinger/Ping", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for Pinger service

type PingerServer interface {
	Ping(context.Context, *PingRequest) (*PingResponse, error)
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

var _Pinger_serviceDesc = grpc.ServiceDesc{
	ServiceName: "ping.Pinger",
	HandlerType: (*PingerServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Ping",
			Handler:    _Pinger_Ping_Handler,
		},
	},
	Streams: []grpc.StreamDesc{},
}

var fileDescriptor0 = []byte{
	// 202 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0xe2, 0xe2, 0x2f, 0xc8, 0xcc, 0x4b,
	0xd7, 0x07, 0x11, 0x7a, 0x05, 0x45, 0xf9, 0x25, 0xf9, 0x42, 0x2c, 0x20, 0xb6, 0x14, 0x5f, 0x7e,
	0x41, 0x6a, 0x51, 0x62, 0x49, 0x7e, 0x11, 0x44, 0x54, 0x89, 0x8f, 0x8b, 0x27, 0x00, 0x28, 0x9e,
	0x5a, 0xe4, 0x9c, 0x9f, 0x97, 0x96, 0x99, 0xae, 0xe4, 0xcd, 0xc5, 0x0d, 0xe2, 0x07, 0xa5, 0x16,
	0x96, 0xa6, 0x16, 0x97, 0x08, 0x69, 0x70, 0xb1, 0x15, 0xe7, 0x97, 0x16, 0x25, 0xa7, 0x4a, 0x30,
	0x2a, 0x30, 0x6a, 0x70, 0x1b, 0x09, 0xe8, 0xc1, 0xf5, 0x07, 0x83, 0xc5, 0x83, 0xa0, 0xf2, 0x42,
	0x42, 0x5c, 0x2c, 0x89, 0x45, 0xe9, 0x86, 0x12, 0x4c, 0x40, 0x75, 0x9c, 0x41, 0x60, 0xb6, 0x92,
	0x05, 0xc4, 0xf0, 0xa0, 0xd4, 0xe2, 0x82, 0xfc, 0xbc, 0xe2, 0x54, 0x90, 0x69, 0xf9, 0xa5, 0x25,
	0x05, 0xa5, 0x25, 0x98, 0xa6, 0xf9, 0x83, 0xc5, 0x83, 0xa0, 0xf2, 0x46, 0x8e, 0x5c, 0x6c, 0x10,
	0x67, 0x09, 0xe9, 0x72, 0xb1, 0x80, 0x58, 0x42, 0x82, 0x7a, 0x60, 0xbf, 0x20, 0x39, 0x4e, 0x4a,
	0x08, 0x59, 0x08, 0x62, 0x85, 0x14, 0xc7, 0xa4, 0x26, 0x49, 0xb0, 0x4f, 0x9d, 0xb8, 0xa3, 0x38,
	0x93, 0x8a, 0x52, 0x13, 0x53, 0x40, 0x9c, 0x24, 0x36, 0xb0, 0x6f, 0x8d, 0x01, 0x01, 0x00, 0x00,
	0xff, 0xff, 0x24, 0x9c, 0x07, 0xea, 0x16, 0x01, 0x00, 0x00,
}
