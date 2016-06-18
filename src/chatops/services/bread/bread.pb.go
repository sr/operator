// Code generated by protoc-gen-go.
// source: bread/bread.proto
// DO NOT EDIT!

/*
Package bread is a generated protocol buffer package.

It is generated from these files:
	bread/bread.proto

It has these top-level messages:
	BreadConfig
	ListAppsRequest
	ListAppsResponse
	EcsDeployRequest
	EcsDeployResponse
*/
package bread

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

type BreadConfig struct {
	AwsRegion       string `protobuf:"bytes,1,opt,name=AwsRegion,json=awsRegion" json:"AwsRegion,omitempty"`
	CanoeEcsService string `protobuf:"bytes,3,opt,name=CanoeEcsService,json=canoeEcsService" json:"CanoeEcsService,omitempty"`
	DeployTimeout   string `protobuf:"bytes,4,opt,name=DeployTimeout,json=deployTimeout" json:"DeployTimeout,omitempty"`
}

func (m *BreadConfig) Reset()                    { *m = BreadConfig{} }
func (m *BreadConfig) String() string            { return proto.CompactTextString(m) }
func (*BreadConfig) ProtoMessage()               {}
func (*BreadConfig) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

type ListAppsRequest struct {
	Source *operator.Source `protobuf:"bytes,1,opt,name=source" json:"source,omitempty"`
}

func (m *ListAppsRequest) Reset()                    { *m = ListAppsRequest{} }
func (m *ListAppsRequest) String() string            { return proto.CompactTextString(m) }
func (*ListAppsRequest) ProtoMessage()               {}
func (*ListAppsRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

func (m *ListAppsRequest) GetSource() *operator.Source {
	if m != nil {
		return m.Source
	}
	return nil
}

type ListAppsResponse struct {
	Output *operator.Output `protobuf:"bytes,1,opt,name=output" json:"output,omitempty"`
}

func (m *ListAppsResponse) Reset()                    { *m = ListAppsResponse{} }
func (m *ListAppsResponse) String() string            { return proto.CompactTextString(m) }
func (*ListAppsResponse) ProtoMessage()               {}
func (*ListAppsResponse) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{2} }

func (m *ListAppsResponse) GetOutput() *operator.Output {
	if m != nil {
		return m.Output
	}
	return nil
}

type EcsDeployRequest struct {
	Source *operator.Source `protobuf:"bytes,1,opt,name=source" json:"source,omitempty"`
	App    string           `protobuf:"bytes,2,opt,name=app" json:"app,omitempty"`
	Build  string           `protobuf:"bytes,3,opt,name=build" json:"build,omitempty"`
}

func (m *EcsDeployRequest) Reset()                    { *m = EcsDeployRequest{} }
func (m *EcsDeployRequest) String() string            { return proto.CompactTextString(m) }
func (*EcsDeployRequest) ProtoMessage()               {}
func (*EcsDeployRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{3} }

func (m *EcsDeployRequest) GetSource() *operator.Source {
	if m != nil {
		return m.Source
	}
	return nil
}

type EcsDeployResponse struct {
	Output *operator.Output `protobuf:"bytes,1,opt,name=output" json:"output,omitempty"`
}

func (m *EcsDeployResponse) Reset()                    { *m = EcsDeployResponse{} }
func (m *EcsDeployResponse) String() string            { return proto.CompactTextString(m) }
func (*EcsDeployResponse) ProtoMessage()               {}
func (*EcsDeployResponse) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{4} }

func (m *EcsDeployResponse) GetOutput() *operator.Output {
	if m != nil {
		return m.Output
	}
	return nil
}

func init() {
	proto.RegisterType((*BreadConfig)(nil), "bread.BreadConfig")
	proto.RegisterType((*ListAppsRequest)(nil), "bread.ListAppsRequest")
	proto.RegisterType((*ListAppsResponse)(nil), "bread.ListAppsResponse")
	proto.RegisterType((*EcsDeployRequest)(nil), "bread.EcsDeployRequest")
	proto.RegisterType((*EcsDeployResponse)(nil), "bread.EcsDeployResponse")
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion2

// Client API for Bread service

type BreadClient interface {
	ListApps(ctx context.Context, in *ListAppsRequest, opts ...grpc.CallOption) (*ListAppsResponse, error)
	EcsDeploy(ctx context.Context, in *EcsDeployRequest, opts ...grpc.CallOption) (*EcsDeployResponse, error)
}

type breadClient struct {
	cc *grpc.ClientConn
}

func NewBreadClient(cc *grpc.ClientConn) BreadClient {
	return &breadClient{cc}
}

func (c *breadClient) ListApps(ctx context.Context, in *ListAppsRequest, opts ...grpc.CallOption) (*ListAppsResponse, error) {
	out := new(ListAppsResponse)
	err := grpc.Invoke(ctx, "/bread.Bread/ListApps", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *breadClient) EcsDeploy(ctx context.Context, in *EcsDeployRequest, opts ...grpc.CallOption) (*EcsDeployResponse, error) {
	out := new(EcsDeployResponse)
	err := grpc.Invoke(ctx, "/bread.Bread/EcsDeploy", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for Bread service

type BreadServer interface {
	ListApps(context.Context, *ListAppsRequest) (*ListAppsResponse, error)
	EcsDeploy(context.Context, *EcsDeployRequest) (*EcsDeployResponse, error)
}

func RegisterBreadServer(s *grpc.Server, srv BreadServer) {
	s.RegisterService(&_Bread_serviceDesc, srv)
}

func _Bread_ListApps_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(ListAppsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BreadServer).ListApps(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Bread/ListApps",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BreadServer).ListApps(ctx, req.(*ListAppsRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Bread_EcsDeploy_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(EcsDeployRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BreadServer).EcsDeploy(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/bread.Bread/EcsDeploy",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BreadServer).EcsDeploy(ctx, req.(*EcsDeployRequest))
	}
	return interceptor(ctx, in, info, handler)
}

var _Bread_serviceDesc = grpc.ServiceDesc{
	ServiceName: "bread.Bread",
	HandlerType: (*BreadServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "ListApps",
			Handler:    _Bread_ListApps_Handler,
		},
		{
			MethodName: "EcsDeploy",
			Handler:    _Bread_EcsDeploy_Handler,
		},
	},
	Streams: []grpc.StreamDesc{},
}

var fileDescriptor0 = []byte{
	// 314 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0x94, 0x52, 0x4f, 0x4b, 0xfb, 0x40,
	0x10, 0x25, 0xbf, 0xfe, 0x52, 0xcc, 0x94, 0x9a, 0x74, 0x11, 0x8d, 0xc1, 0x83, 0x04, 0x0f, 0x3d,
	0x45, 0xa8, 0xc7, 0xaa, 0x50, 0xab, 0x37, 0x41, 0x48, 0xfd, 0x02, 0xf9, 0xb3, 0x96, 0x85, 0x9a,
	0x59, 0x77, 0x13, 0x45, 0xbc, 0xf9, 0x05, 0x04, 0x3f, 0xb1, 0x9b, 0xdd, 0xa4, 0xd6, 0xe6, 0xd4,
	0x4b, 0xc8, 0xbe, 0x37, 0x6f, 0xdf, 0x9b, 0x9d, 0x81, 0x51, 0x2a, 0x68, 0x92, 0x9f, 0xeb, 0x6f,
	0xc4, 0x05, 0x96, 0x48, 0x6c, 0x7d, 0x08, 0xf6, 0x91, 0x53, 0x91, 0x94, 0x28, 0x0c, 0x1c, 0x7e,
	0xc0, 0xe0, 0xa6, 0x26, 0xe6, 0x58, 0x3c, 0xb1, 0x25, 0x39, 0x01, 0x67, 0xf6, 0x26, 0x63, 0xba,
	0x64, 0x58, 0xf8, 0xd6, 0xa9, 0x35, 0x76, 0x62, 0x27, 0x69, 0x01, 0x32, 0x06, 0x77, 0x9e, 0x14,
	0x48, 0xef, 0x32, 0xb9, 0xa0, 0xe2, 0x95, 0x65, 0xd4, 0xef, 0xe9, 0x1a, 0x37, 0xfb, 0x0b, 0x93,
	0x33, 0x18, 0xde, 0x52, 0xbe, 0xc2, 0xf7, 0x47, 0xf6, 0x4c, 0xb1, 0x2a, 0xfd, 0xff, 0xba, 0x6e,
	0x98, 0x6f, 0x82, 0xe1, 0x14, 0xdc, 0x7b, 0x26, 0xcb, 0x19, 0xe7, 0xca, 0xe1, 0xa5, 0xa2, 0xb2,
	0x54, 0x16, 0x7d, 0x89, 0x95, 0x50, 0x37, 0xd7, 0xee, 0x83, 0x89, 0x17, 0xad, 0x03, 0x2f, 0x34,
	0x1e, 0x37, 0x7c, 0x78, 0x09, 0xde, 0xaf, 0x58, 0x72, 0x2c, 0x24, 0xad, 0xd5, 0xea, 0x5e, 0xae,
	0xfc, 0x3a, 0xea, 0x07, 0x8d, 0xc7, 0x0d, 0x1f, 0xe6, 0xe0, 0xa9, 0xb8, 0x26, 0xe3, 0xce, 0xde,
	0xc4, 0x83, 0x5e, 0xc2, 0xb9, 0xff, 0x4f, 0x37, 0x55, 0xff, 0x92, 0x03, 0xb0, 0xd3, 0x8a, 0xad,
	0xf2, 0xe6, 0x41, 0xcc, 0x21, 0xbc, 0x82, 0xd1, 0x86, 0xcb, 0xae, 0x21, 0x27, 0x5f, 0x16, 0xd8,
	0x7a, 0x3a, 0x64, 0x0a, 0x7b, 0x6d, 0xb3, 0xe4, 0x30, 0x32, 0x73, 0xdd, 0x7a, 0xba, 0xe0, 0xa8,
	0x83, 0x37, 0x86, 0xd7, 0xe0, 0xac, 0x53, 0x90, 0xb6, 0x6a, 0xbb, 0xfb, 0xc0, 0xef, 0x12, 0x46,
	0x1f, 0x38, 0xdf, 0x9f, 0xc7, 0x66, 0x7d, 0xd2, 0xbe, 0xde, 0x9a, 0x8b, 0x9f, 0x00, 0x00, 0x00,
	0xff, 0xff, 0xd1, 0x45, 0xba, 0x3c, 0x61, 0x02, 0x00, 0x00,
}
