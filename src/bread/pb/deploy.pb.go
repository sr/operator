// Code generated by protoc-gen-go.
// source: pb/deploy.proto
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

type ListAppsRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
}

func (m *ListAppsRequest) Reset()                    { *m = ListAppsRequest{} }
func (m *ListAppsRequest) String() string            { return proto.CompactTextString(m) }
func (*ListAppsRequest) ProtoMessage()               {}
func (*ListAppsRequest) Descriptor() ([]byte, []int) { return fileDescriptor2, []int{0} }

func (m *ListAppsRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

type TriggerRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
	App     string            `protobuf:"bytes,2,opt,name=app" json:"app,omitempty"`
	Build   string            `protobuf:"bytes,3,opt,name=build" json:"build,omitempty"`
}

func (m *TriggerRequest) Reset()                    { *m = TriggerRequest{} }
func (m *TriggerRequest) String() string            { return proto.CompactTextString(m) }
func (*TriggerRequest) ProtoMessage()               {}
func (*TriggerRequest) Descriptor() ([]byte, []int) { return fileDescriptor2, []int{1} }

func (m *TriggerRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

func init() {
	proto.RegisterType((*ListAppsRequest)(nil), "bread.ListAppsRequest")
	proto.RegisterType((*TriggerRequest)(nil), "bread.TriggerRequest")
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion3

// Client API for Deploy service

type DeployClient interface {
	ListApps(ctx context.Context, in *ListAppsRequest, opts ...grpc.CallOption) (*operator.Response, error)
	Trigger(ctx context.Context, in *TriggerRequest, opts ...grpc.CallOption) (*operator.Response, error)
}

type deployClient struct {
	cc *grpc.ClientConn
}

func NewDeployClient(cc *grpc.ClientConn) DeployClient {
	return &deployClient{cc}
}

func (c *deployClient) ListApps(ctx context.Context, in *ListAppsRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/bread.Deploy/ListApps", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *deployClient) Trigger(ctx context.Context, in *TriggerRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/bread.Deploy/Trigger", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for Deploy service

type DeployServer interface {
	ListApps(context.Context, *ListAppsRequest) (*operator.Response, error)
	Trigger(context.Context, *TriggerRequest) (*operator.Response, error)
}

func RegisterDeployServer(s *grpc.Server, srv DeployServer) {
	s.RegisterService(&_Deploy_serviceDesc, srv)
}

func _Deploy_ListApps_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(ListAppsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(DeployServer).ListApps(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Deploy/ListApps",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(DeployServer).ListApps(ctx, req.(*ListAppsRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Deploy_Trigger_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(TriggerRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(DeployServer).Trigger(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Deploy/Trigger",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(DeployServer).Trigger(ctx, req.(*TriggerRequest))
	}
	return interceptor(ctx, in, info, handler)
}

var _Deploy_serviceDesc = grpc.ServiceDesc{
	ServiceName: "bread.Deploy",
	HandlerType: (*DeployServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "ListApps",
			Handler:    _Deploy_ListApps_Handler,
		},
		{
			MethodName: "Trigger",
			Handler:    _Deploy_Trigger_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: fileDescriptor2,
}

func init() { proto.RegisterFile("pb/deploy.proto", fileDescriptor2) }

var fileDescriptor2 = []byte{
	// 216 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0xe2, 0xe2, 0x2f, 0x48, 0xd2, 0x4f,
	0x49, 0x2d, 0xc8, 0xc9, 0xaf, 0xd4, 0x2b, 0x28, 0xca, 0x2f, 0xc9, 0x17, 0x62, 0x4d, 0x2a, 0x4a,
	0x4d, 0x4c, 0x91, 0xe2, 0xcb, 0x2f, 0x48, 0x2d, 0x4a, 0x2c, 0xc9, 0x2f, 0x82, 0x08, 0x2b, 0xd9,
	0x71, 0xf1, 0xfb, 0x64, 0x16, 0x97, 0x38, 0x16, 0x14, 0x14, 0x07, 0xa5, 0x16, 0x96, 0xa6, 0x16,
	0x97, 0x08, 0x69, 0x73, 0xb1, 0x17, 0x41, 0x98, 0x12, 0x8c, 0x0a, 0x8c, 0x1a, 0xdc, 0x46, 0x82,
	0x7a, 0x70, 0x4d, 0x50, 0x35, 0x41, 0x30, 0x15, 0x4a, 0xa9, 0x5c, 0x7c, 0x21, 0x45, 0x99, 0xe9,
	0xe9, 0xa9, 0x45, 0xe4, 0x68, 0x17, 0x12, 0xe0, 0x62, 0x4e, 0x2c, 0x28, 0x90, 0x60, 0x52, 0x60,
	0xd4, 0xe0, 0x0c, 0x02, 0x31, 0x85, 0x44, 0xb8, 0x58, 0x93, 0x4a, 0x33, 0x73, 0x52, 0x24, 0x98,
	0xc1, 0x62, 0x10, 0x8e, 0x51, 0x13, 0x23, 0x17, 0x9b, 0x0b, 0xd8, 0x3b, 0x42, 0x66, 0x5c, 0x1c,
	0x30, 0x17, 0x0b, 0x89, 0xe9, 0x81, 0x7d, 0xa5, 0x87, 0xe6, 0x05, 0x29, 0x21, 0x64, 0x2b, 0x8b,
	0x0b, 0xf2, 0xf3, 0x8a, 0x53, 0x85, 0x4c, 0xb8, 0xd8, 0xa1, 0x2e, 0x15, 0x12, 0x85, 0x6a, 0x43,
	0x75, 0x39, 0x36, 0x5d, 0x52, 0x5c, 0x93, 0x9a, 0x24, 0xd9, 0x20, 0x01, 0xe9, 0xc4, 0x19, 0xc5,
	0x0e, 0xd6, 0x57, 0x90, 0x94, 0xc4, 0x06, 0x0e, 0x3d, 0x63, 0x40, 0x00, 0x00, 0x00, 0xff, 0xff,
	0xc5, 0xbc, 0x6b, 0xc0, 0x67, 0x01, 0x00, 0x00,
}
