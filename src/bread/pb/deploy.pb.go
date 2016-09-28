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

type ListTargetsRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
}

func (m *ListTargetsRequest) Reset()                    { *m = ListTargetsRequest{} }
func (m *ListTargetsRequest) String() string            { return proto.CompactTextString(m) }
func (*ListTargetsRequest) ProtoMessage()               {}
func (*ListTargetsRequest) Descriptor() ([]byte, []int) { return fileDescriptor1, []int{0} }

func (m *ListTargetsRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

type ListBuildsRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
	Target  string            `protobuf:"bytes,2,opt,name=target" json:"target,omitempty"`
	Branch  string            `protobuf:"bytes,3,opt,name=branch" json:"branch,omitempty"`
}

func (m *ListBuildsRequest) Reset()                    { *m = ListBuildsRequest{} }
func (m *ListBuildsRequest) String() string            { return proto.CompactTextString(m) }
func (*ListBuildsRequest) ProtoMessage()               {}
func (*ListBuildsRequest) Descriptor() ([]byte, []int) { return fileDescriptor1, []int{1} }

func (m *ListBuildsRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

type TriggerRequest struct {
	Request *operator.Request `protobuf:"bytes,1,opt,name=request" json:"request,omitempty"`
	Target  string            `protobuf:"bytes,2,opt,name=target" json:"target,omitempty"`
	Build   string            `protobuf:"bytes,3,opt,name=build" json:"build,omitempty"`
}

func (m *TriggerRequest) Reset()                    { *m = TriggerRequest{} }
func (m *TriggerRequest) String() string            { return proto.CompactTextString(m) }
func (*TriggerRequest) ProtoMessage()               {}
func (*TriggerRequest) Descriptor() ([]byte, []int) { return fileDescriptor1, []int{2} }

func (m *TriggerRequest) GetRequest() *operator.Request {
	if m != nil {
		return m.Request
	}
	return nil
}

func init() {
	proto.RegisterType((*ListTargetsRequest)(nil), "bread.ListTargetsRequest")
	proto.RegisterType((*ListBuildsRequest)(nil), "bread.ListBuildsRequest")
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
	ListTargets(ctx context.Context, in *ListTargetsRequest, opts ...grpc.CallOption) (*operator.Response, error)
	ListBuilds(ctx context.Context, in *ListBuildsRequest, opts ...grpc.CallOption) (*operator.Response, error)
	Trigger(ctx context.Context, in *TriggerRequest, opts ...grpc.CallOption) (*operator.Response, error)
}

type deployClient struct {
	cc *grpc.ClientConn
}

func NewDeployClient(cc *grpc.ClientConn) DeployClient {
	return &deployClient{cc}
}

func (c *deployClient) ListTargets(ctx context.Context, in *ListTargetsRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/bread.Deploy/ListTargets", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *deployClient) ListBuilds(ctx context.Context, in *ListBuildsRequest, opts ...grpc.CallOption) (*operator.Response, error) {
	out := new(operator.Response)
	err := grpc.Invoke(ctx, "/bread.Deploy/ListBuilds", in, out, c.cc, opts...)
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
	ListTargets(context.Context, *ListTargetsRequest) (*operator.Response, error)
	ListBuilds(context.Context, *ListBuildsRequest) (*operator.Response, error)
	Trigger(context.Context, *TriggerRequest) (*operator.Response, error)
}

func RegisterDeployServer(s *grpc.Server, srv DeployServer) {
	s.RegisterService(&_Deploy_serviceDesc, srv)
}

func _Deploy_ListTargets_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(ListTargetsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(DeployServer).ListTargets(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Deploy/ListTargets",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(DeployServer).ListTargets(ctx, req.(*ListTargetsRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Deploy_ListBuilds_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(ListBuildsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(DeployServer).ListBuilds(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Deploy/ListBuilds",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(DeployServer).ListBuilds(ctx, req.(*ListBuildsRequest))
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
			MethodName: "ListTargets",
			Handler:    _Deploy_ListTargets_Handler,
		},
		{
			MethodName: "ListBuilds",
			Handler:    _Deploy_ListBuilds_Handler,
		},
		{
			MethodName: "Trigger",
			Handler:    _Deploy_Trigger_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: fileDescriptor1,
}

func init() { proto.RegisterFile("pb/deploy.proto", fileDescriptor1) }

var fileDescriptor1 = []byte{
	// 257 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0xe2, 0xe2, 0x2f, 0x48, 0xd2, 0x4f,
	0x49, 0x2d, 0xc8, 0xc9, 0xaf, 0xd4, 0x2b, 0x28, 0xca, 0x2f, 0xc9, 0x17, 0x62, 0x4d, 0x2a, 0x4a,
	0x4d, 0x4c, 0x91, 0xe2, 0xcb, 0x2f, 0x48, 0x2d, 0x4a, 0x2c, 0xc9, 0x2f, 0x82, 0x08, 0x2b, 0x39,
	0x72, 0x09, 0xf9, 0x64, 0x16, 0x97, 0x84, 0x24, 0x16, 0xa5, 0xa7, 0x96, 0x14, 0x07, 0xa5, 0x16,
	0x96, 0xa6, 0x16, 0x97, 0x08, 0x69, 0x73, 0xb1, 0x17, 0x41, 0x98, 0x12, 0x8c, 0x0a, 0x8c, 0x1a,
	0xdc, 0x46, 0x82, 0x7a, 0x70, 0x7d, 0x50, 0x35, 0x41, 0x30, 0x15, 0x4a, 0x05, 0x5c, 0x82, 0x20,
	0x23, 0x9c, 0x4a, 0x33, 0x73, 0x52, 0xc8, 0x32, 0x41, 0x48, 0x8c, 0x8b, 0xad, 0x04, 0xec, 0x00,
	0x09, 0x26, 0x05, 0x46, 0x0d, 0xce, 0x20, 0x28, 0x0f, 0x24, 0x9e, 0x54, 0x94, 0x98, 0x97, 0x9c,
	0x21, 0xc1, 0x0c, 0x11, 0x87, 0xf0, 0x94, 0xb2, 0xb9, 0xf8, 0x42, 0x8a, 0x32, 0xd3, 0xd3, 0x53,
	0x8b, 0xa8, 0x6a, 0x9d, 0x08, 0x17, 0x6b, 0x12, 0xc8, 0x13, 0x50, 0xdb, 0x20, 0x1c, 0xa3, 0x23,
	0x8c, 0x5c, 0x6c, 0x2e, 0xe0, 0x90, 0x14, 0xb2, 0xe1, 0xe2, 0x46, 0x0a, 0x2c, 0x21, 0x49, 0x3d,
	0x70, 0x98, 0xea, 0x61, 0x06, 0xa0, 0x94, 0x10, 0xb2, 0xf5, 0xc5, 0x05, 0xf9, 0x79, 0xc5, 0xa9,
	0x42, 0x56, 0x5c, 0x5c, 0x88, 0x70, 0x12, 0x92, 0x40, 0xd2, 0x8c, 0x12, 0x74, 0x58, 0xf5, 0x9a,
	0x70, 0xb1, 0x43, 0x7d, 0x2c, 0x24, 0x0a, 0xd5, 0x88, 0x1a, 0x02, 0xd8, 0x74, 0x49, 0x71, 0x4d,
	0x6a, 0x92, 0x64, 0x83, 0xa4, 0x02, 0x27, 0xce, 0x28, 0x76, 0xb0, 0xbe, 0x82, 0xa4, 0x24, 0x36,
	0x70, 0xd4, 0x1b, 0x03, 0x02, 0x00, 0x00, 0xff, 0xff, 0xdc, 0x3c, 0xc5, 0x5f, 0x24, 0x02, 0x00,
	0x00,
}
