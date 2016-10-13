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
	// List what can be deployed
	ListTargets(ctx context.Context, in *ListTargetsRequest, opts ...grpc.CallOption) (*operator.Response, error)
	// List the ten most recent builds for a given target
	ListBuilds(ctx context.Context, in *ListBuildsRequest, opts ...grpc.CallOption) (*operator.Response, error)
	// Trigger a deploy of a build to given target
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
	// List what can be deployed
	ListTargets(context.Context, *ListTargetsRequest) (*operator.Response, error)
	// List the ten most recent builds for a given target
	ListBuilds(context.Context, *ListBuildsRequest) (*operator.Response, error)
	// Trigger a deploy of a build to given target
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
	// 263 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0xac, 0x91, 0x41, 0x4b, 0xc3, 0x40,
	0x10, 0x85, 0x89, 0xd2, 0x84, 0x4e, 0x41, 0xe9, 0xa0, 0x12, 0x7b, 0x2a, 0x01, 0xa1, 0x20, 0x6c,
	0xa0, 0x7a, 0x12, 0x2f, 0x16, 0x8f, 0x9e, 0x42, 0x4f, 0xde, 0xb2, 0xcd, 0x90, 0x06, 0x6b, 0x77,
	0x9d, 0xdd, 0x1c, 0xfc, 0x67, 0xfe, 0x3c, 0xc9, 0xee, 0x6a, 0x53, 0xec, 0x49, 0x7a, 0x9b, 0x19,
	0xde, 0x9b, 0xb7, 0xf3, 0x2d, 0x9c, 0x6b, 0x99, 0x57, 0xa4, 0x37, 0xea, 0x53, 0x68, 0x56, 0x56,
	0xe1, 0x40, 0x32, 0x95, 0xd5, 0xe4, 0xa6, 0x6e, 0xec, 0xba, 0x95, 0x62, 0xa5, 0xde, 0x73, 0xc3,
	0xb9, 0xd2, 0xc4, 0xa5, 0x55, 0xbb, 0xc2, 0xab, 0xb3, 0x27, 0xc0, 0x97, 0xc6, 0xd8, 0x65, 0xc9,
	0x35, 0x59, 0x53, 0xd0, 0x47, 0x4b, 0xc6, 0xe2, 0x2d, 0x24, 0xec, 0xcb, 0x34, 0x9a, 0x46, 0xb3,
	0xd1, 0x7c, 0x2c, 0x7e, 0x7d, 0x41, 0x53, 0xfc, 0x28, 0x32, 0x0d, 0xe3, 0x6e, 0xc5, 0xa2, 0x6d,
	0x36, 0xd5, 0xbf, 0x36, 0xe0, 0x15, 0xc4, 0xd6, 0x3d, 0x20, 0x3d, 0x99, 0x46, 0xb3, 0x61, 0x11,
	0xba, 0x6e, 0x2e, 0xb9, 0xdc, 0xae, 0xd6, 0xe9, 0xa9, 0x9f, 0xfb, 0x2e, 0x7b, 0x83, 0xb3, 0x25,
	0x37, 0x75, 0x4d, 0x7c, 0xd4, 0xb8, 0x0b, 0x18, 0xc8, 0xee, 0x88, 0x90, 0xe6, 0x9b, 0xf9, 0x57,
	0x04, 0xf1, 0xb3, 0x03, 0x8c, 0x8f, 0x30, 0xea, 0xc1, 0xc2, 0x6b, 0xe1, 0x50, 0x8b, 0xbf, 0x00,
	0x27, 0xd8, 0x8f, 0x37, 0x5a, 0x6d, 0x0d, 0xe1, 0x03, 0xc0, 0x8e, 0x13, 0xa6, 0x3d, 0xf3, 0x1e,
	0xba, 0x83, 0xde, 0x7b, 0x48, 0xc2, 0xc5, 0x78, 0x19, 0x8c, 0xfb, 0x04, 0x0e, 0xb9, 0x16, 0xc3,
	0xd7, 0xc4, 0x69, 0xb5, 0x94, 0xb1, 0xfb, 0xee, 0xbb, 0xef, 0x00, 0x00, 0x00, 0xff, 0xff, 0x7c,
	0x01, 0x5d, 0x7f, 0x2f, 0x02, 0x00, 0x00,
}
