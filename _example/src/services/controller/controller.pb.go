// Code generated by protoc-gen-go.
// source: services/controller/controller.proto
// DO NOT EDIT!

/*
Package controller is a generated protocol buffer package.

It is generated from these files:
	services/controller/controller.proto

It has these top-level messages:
	CreateClusterRequest
	DeployRequest
	CreateClusterResponse
	DeployResponse
*/
package controller

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

type CreateClusterRequest struct {
}

func (m *CreateClusterRequest) Reset()                    { *m = CreateClusterRequest{} }
func (m *CreateClusterRequest) String() string            { return proto.CompactTextString(m) }
func (*CreateClusterRequest) ProtoMessage()               {}
func (*CreateClusterRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

type DeployRequest struct {
	BuildId          string `protobuf:"bytes,1,opt,name=build_id" json:"build_id,omitempty"`
	HubotBuildId     string `protobuf:"bytes,2,opt,name=hubot_build_id" json:"hubot_build_id,omitempty"`
	OperatordBuildId string `protobuf:"bytes,3,opt,name=operatord_build_id" json:"operatord_build_id,omitempty"`
}

func (m *DeployRequest) Reset()                    { *m = DeployRequest{} }
func (m *DeployRequest) String() string            { return proto.CompactTextString(m) }
func (*DeployRequest) ProtoMessage()               {}
func (*DeployRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

type CreateClusterResponse struct {
	Output *operator.Output `protobuf:"bytes,1,opt,name=output" json:"output,omitempty"`
}

func (m *CreateClusterResponse) Reset()                    { *m = CreateClusterResponse{} }
func (m *CreateClusterResponse) String() string            { return proto.CompactTextString(m) }
func (*CreateClusterResponse) ProtoMessage()               {}
func (*CreateClusterResponse) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{2} }

func (m *CreateClusterResponse) GetOutput() *operator.Output {
	if m != nil {
		return m.Output
	}
	return nil
}

type DeployResponse struct {
	Output *operator.Output `protobuf:"bytes,1,opt,name=output" json:"output,omitempty"`
}

func (m *DeployResponse) Reset()                    { *m = DeployResponse{} }
func (m *DeployResponse) String() string            { return proto.CompactTextString(m) }
func (*DeployResponse) ProtoMessage()               {}
func (*DeployResponse) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{3} }

func (m *DeployResponse) GetOutput() *operator.Output {
	if m != nil {
		return m.Output
	}
	return nil
}

func init() {
	proto.RegisterType((*CreateClusterRequest)(nil), "controller.CreateClusterRequest")
	proto.RegisterType((*DeployRequest)(nil), "controller.DeployRequest")
	proto.RegisterType((*CreateClusterResponse)(nil), "controller.CreateClusterResponse")
	proto.RegisterType((*DeployResponse)(nil), "controller.DeployResponse")
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// Client API for Controller service

type ControllerClient interface {
	CreateCluster(ctx context.Context, in *CreateClusterRequest, opts ...grpc.CallOption) (*CreateClusterResponse, error)
	Deploy(ctx context.Context, in *DeployRequest, opts ...grpc.CallOption) (*DeployResponse, error)
}

type controllerClient struct {
	cc *grpc.ClientConn
}

func NewControllerClient(cc *grpc.ClientConn) ControllerClient {
	return &controllerClient{cc}
}

func (c *controllerClient) CreateCluster(ctx context.Context, in *CreateClusterRequest, opts ...grpc.CallOption) (*CreateClusterResponse, error) {
	out := new(CreateClusterResponse)
	err := grpc.Invoke(ctx, "/controller.Controller/CreateCluster", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *controllerClient) Deploy(ctx context.Context, in *DeployRequest, opts ...grpc.CallOption) (*DeployResponse, error) {
	out := new(DeployResponse)
	err := grpc.Invoke(ctx, "/controller.Controller/Deploy", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for Controller service

type ControllerServer interface {
	CreateCluster(context.Context, *CreateClusterRequest) (*CreateClusterResponse, error)
	Deploy(context.Context, *DeployRequest) (*DeployResponse, error)
}

func RegisterControllerServer(s *grpc.Server, srv ControllerServer) {
	s.RegisterService(&_Controller_serviceDesc, srv)
}

func _Controller_CreateCluster_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error) (interface{}, error) {
	in := new(CreateClusterRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	out, err := srv.(ControllerServer).CreateCluster(ctx, in)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func _Controller_Deploy_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error) (interface{}, error) {
	in := new(DeployRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	out, err := srv.(ControllerServer).Deploy(ctx, in)
	if err != nil {
		return nil, err
	}
	return out, nil
}

var _Controller_serviceDesc = grpc.ServiceDesc{
	ServiceName: "controller.Controller",
	HandlerType: (*ControllerServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "CreateCluster",
			Handler:    _Controller_CreateCluster_Handler,
		},
		{
			MethodName: "Deploy",
			Handler:    _Controller_Deploy_Handler,
		},
	},
	Streams: []grpc.StreamDesc{},
}

var fileDescriptor0 = []byte{
	// 250 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0xe2, 0x52, 0x29, 0x4e, 0x2d, 0x2a,
	0xcb, 0x4c, 0x4e, 0x2d, 0xd6, 0x4f, 0xce, 0xcf, 0x2b, 0x29, 0xca, 0xcf, 0xc9, 0x49, 0x2d, 0x42,
	0x62, 0xea, 0x15, 0x14, 0xe5, 0x97, 0xe4, 0x0b, 0x71, 0x21, 0x44, 0xa4, 0xf8, 0xf2, 0x0b, 0x52,
	0x8b, 0x12, 0x4b, 0xf2, 0xa1, 0x72, 0x4a, 0x62, 0x5c, 0x22, 0xce, 0x45, 0xa9, 0x89, 0x25, 0xa9,
	0xce, 0x39, 0xa5, 0xc5, 0x25, 0xa9, 0x45, 0x41, 0xa9, 0x85, 0xa5, 0xa9, 0xc5, 0x25, 0x4a, 0xa1,
	0x5c, 0xbc, 0x2e, 0xa9, 0x05, 0x39, 0xf9, 0x95, 0x50, 0x01, 0x21, 0x01, 0x2e, 0x8e, 0xa4, 0xd2,
	0xcc, 0x9c, 0x94, 0xf8, 0xcc, 0x14, 0x09, 0x46, 0x05, 0x46, 0x0d, 0x4e, 0x21, 0x31, 0x2e, 0xbe,
	0x8c, 0xd2, 0xa4, 0xfc, 0x92, 0x78, 0xb8, 0x38, 0x13, 0x58, 0x5c, 0x8a, 0x4b, 0x08, 0x66, 0x49,
	0x0a, 0x42, 0x8e, 0x19, 0x24, 0xa7, 0x64, 0xc9, 0x25, 0x8a, 0x66, 0x5d, 0x71, 0x41, 0x7e, 0x5e,
	0x71, 0xaa, 0x90, 0x02, 0x17, 0x5b, 0x7e, 0x69, 0x49, 0x41, 0x69, 0x09, 0xd8, 0x70, 0x6e, 0x23,
	0x01, 0x3d, 0xb8, 0x43, 0xfd, 0xc1, 0xe2, 0x4a, 0x46, 0x5c, 0x7c, 0x30, 0x17, 0x11, 0xab, 0xc7,
	0x68, 0x33, 0x23, 0x17, 0x97, 0x33, 0xdc, 0xf3, 0x42, 0x21, 0x5c, 0xbc, 0x28, 0xb6, 0x0b, 0x29,
	0xe8, 0x21, 0x05, 0x16, 0xb6, 0x70, 0x90, 0x52, 0xc4, 0xa3, 0x02, 0xea, 0x0c, 0x7b, 0x2e, 0x36,
	0x88, 0xc3, 0x84, 0x24, 0x91, 0x15, 0xa3, 0x04, 0x9f, 0x94, 0x14, 0x36, 0x29, 0x88, 0x01, 0x52,
	0x7c, 0x93, 0x9a, 0x24, 0x91, 0xe2, 0x28, 0x89, 0x0d, 0x1c, 0x35, 0xc6, 0x80, 0x00, 0x00, 0x00,
	0xff, 0xff, 0xd6, 0x19, 0x8d, 0x3d, 0xde, 0x01, 0x00, 0x00,
}
