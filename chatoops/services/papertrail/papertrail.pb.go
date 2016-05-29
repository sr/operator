// Code generated by protoc-gen-go.
// source: papertrail/papertrail.proto
// DO NOT EDIT!

/*
Package papertrail is a generated protocol buffer package.

It is generated from these files:
	papertrail/papertrail.proto

It has these top-level messages:
	PapertrailServiceConfig
	SearchRequest
	SearchResponse
	LogEvent
*/
package papertrail

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

type PapertrailServiceConfig struct {
	ApiKey string `protobuf:"bytes,1,opt,name=api_key,json=apiKey" json:"api_key,omitempty"`
}

func (m *PapertrailServiceConfig) Reset()                    { *m = PapertrailServiceConfig{} }
func (m *PapertrailServiceConfig) String() string            { return proto.CompactTextString(m) }
func (*PapertrailServiceConfig) ProtoMessage()               {}
func (*PapertrailServiceConfig) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

type SearchRequest struct {
	Source *operator.Source `protobuf:"bytes,1,opt,name=source" json:"source,omitempty"`
	Query  string           `protobuf:"bytes,2,opt,name=query" json:"query,omitempty"`
}

func (m *SearchRequest) Reset()                    { *m = SearchRequest{} }
func (m *SearchRequest) String() string            { return proto.CompactTextString(m) }
func (*SearchRequest) ProtoMessage()               {}
func (*SearchRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

func (m *SearchRequest) GetSource() *operator.Source {
	if m != nil {
		return m.Source
	}
	return nil
}

type SearchResponse struct {
	Output  *operator.Output `protobuf:"bytes,1,opt,name=output" json:"output,omitempty"`
	Objects []*LogEvent      `protobuf:"bytes,2,rep,name=objects" json:"objects,omitempty"`
}

func (m *SearchResponse) Reset()                    { *m = SearchResponse{} }
func (m *SearchResponse) String() string            { return proto.CompactTextString(m) }
func (*SearchResponse) ProtoMessage()               {}
func (*SearchResponse) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{2} }

func (m *SearchResponse) GetOutput() *operator.Output {
	if m != nil {
		return m.Output
	}
	return nil
}

func (m *SearchResponse) GetObjects() []*LogEvent {
	if m != nil {
		return m.Objects
	}
	return nil
}

type LogEvent struct {
	Id         string `protobuf:"bytes,1,opt,name=id" json:"id,omitempty"`
	Source     string `protobuf:"bytes,2,opt,name=source" json:"source,omitempty"`
	Program    string `protobuf:"bytes,3,opt,name=program" json:"program,omitempty"`
	LogMessage string `protobuf:"bytes,4,opt,name=log_message,json=logMessage" json:"log_message,omitempty"`
}

func (m *LogEvent) Reset()                    { *m = LogEvent{} }
func (m *LogEvent) String() string            { return proto.CompactTextString(m) }
func (*LogEvent) ProtoMessage()               {}
func (*LogEvent) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{3} }

func init() {
	proto.RegisterType((*PapertrailServiceConfig)(nil), "papertrail.PapertrailServiceConfig")
	proto.RegisterType((*SearchRequest)(nil), "papertrail.SearchRequest")
	proto.RegisterType((*SearchResponse)(nil), "papertrail.SearchResponse")
	proto.RegisterType((*LogEvent)(nil), "papertrail.LogEvent")
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion2

// Client API for PapertrailService service

type PapertrailServiceClient interface {
	Search(ctx context.Context, in *SearchRequest, opts ...grpc.CallOption) (*SearchResponse, error)
}

type papertrailServiceClient struct {
	cc *grpc.ClientConn
}

func NewPapertrailServiceClient(cc *grpc.ClientConn) PapertrailServiceClient {
	return &papertrailServiceClient{cc}
}

func (c *papertrailServiceClient) Search(ctx context.Context, in *SearchRequest, opts ...grpc.CallOption) (*SearchResponse, error) {
	out := new(SearchResponse)
	err := grpc.Invoke(ctx, "/papertrail.PapertrailService/Search", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for PapertrailService service

type PapertrailServiceServer interface {
	Search(context.Context, *SearchRequest) (*SearchResponse, error)
}

func RegisterPapertrailServiceServer(s *grpc.Server, srv PapertrailServiceServer) {
	s.RegisterService(&_PapertrailService_serviceDesc, srv)
}

func _PapertrailService_Search_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(SearchRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PapertrailServiceServer).Search(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/papertrail.PapertrailService/Search",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PapertrailServiceServer).Search(ctx, req.(*SearchRequest))
	}
	return interceptor(ctx, in, info, handler)
}

var _PapertrailService_serviceDesc = grpc.ServiceDesc{
	ServiceName: "papertrail.PapertrailService",
	HandlerType: (*PapertrailServiceServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Search",
			Handler:    _PapertrailService_Search_Handler,
		},
	},
	Streams: []grpc.StreamDesc{},
}

var fileDescriptor0 = []byte{
	// 307 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0x6c, 0x91, 0xc1, 0x4e, 0x83, 0x40,
	0x10, 0x86, 0xd3, 0x56, 0xa9, 0x4e, 0x23, 0xd1, 0x4d, 0x63, 0x29, 0x1e, 0x34, 0x9c, 0x7a, 0xc2,
	0xa4, 0x3e, 0x80, 0x07, 0xe3, 0x49, 0x4d, 0x0d, 0x3c, 0x40, 0xb3, 0xa5, 0x23, 0x52, 0x0b, 0xbb,
	0xee, 0x2e, 0x4d, 0xb8, 0xfa, 0x08, 0x3e, 0xb1, 0xeb, 0x2e, 0x50, 0x4c, 0xbd, 0xcd, 0xfc, 0xdf,
	0xf0, 0x33, 0xf3, 0x2f, 0x5c, 0x71, 0xca, 0x51, 0x28, 0x41, 0xb3, 0xed, 0xed, 0xbe, 0x0c, 0xb9,
	0x60, 0x8a, 0x11, 0xd8, 0x2b, 0xbe, 0xcb, 0x74, 0x49, 0x15, 0x13, 0x96, 0x05, 0x73, 0x98, 0xbc,
	0xb6, 0x34, 0x46, 0xb1, 0xcb, 0x12, 0x7c, 0x60, 0xc5, 0x5b, 0x96, 0x92, 0x09, 0x0c, 0x29, 0xcf,
	0x96, 0x1f, 0x58, 0x79, 0xbd, 0x9b, 0xde, 0xec, 0x34, 0x72, 0x74, 0xfb, 0x84, 0x55, 0xb0, 0x80,
	0xb3, 0x18, 0xa9, 0x48, 0xde, 0x23, 0xfc, 0x2c, 0x51, 0x2a, 0x32, 0x03, 0x47, 0xb2, 0x52, 0x24,
	0x68, 0x06, 0x47, 0xf3, 0xf3, 0xb0, 0xfd, 0x4b, 0x6c, 0xf4, 0xa8, 0xe6, 0x64, 0x0c, 0xc7, 0xfa,
	0x13, 0x51, 0x79, 0x7d, 0xe3, 0x68, 0x9b, 0x60, 0x03, 0x6e, 0x63, 0x28, 0x39, 0x2b, 0x24, 0xfe,
	0x3a, 0xb2, 0x52, 0xf1, 0x52, 0x1d, 0x3a, 0x2e, 0x8c, 0x1e, 0xd5, 0x9c, 0x84, 0x30, 0x64, 0xab,
	0x0d, 0x26, 0x4a, 0x6a, 0xcf, 0x81, 0x1e, 0x1d, 0x87, 0x9d, 0x00, 0x9e, 0x59, 0xfa, 0xb8, 0xc3,
	0x42, 0x45, 0xcd, 0x50, 0x90, 0xc3, 0x49, 0x23, 0x12, 0x17, 0xfa, 0xd9, 0xba, 0x3e, 0x4e, 0x57,
	0xe4, 0xb2, 0xbd, 0xc3, 0xae, 0xd7, 0x6c, 0xed, 0xc1, 0x50, 0xa7, 0x95, 0x0a, 0x9a, 0x7b, 0x03,
	0x03, 0x9a, 0x96, 0x5c, 0xc3, 0x68, 0xcb, 0xd2, 0x65, 0x8e, 0x52, 0xd2, 0x14, 0xbd, 0x23, 0x43,
	0x41, 0x4b, 0x2f, 0x56, 0x99, 0xaf, 0xe1, 0xe2, 0x20, 0x5f, 0x72, 0x0f, 0x8e, 0xbd, 0x97, 0x4c,
	0xbb, 0xcb, 0xfe, 0x09, 0xd5, 0xf7, 0xff, 0x43, 0x36, 0x1e, 0xdf, 0xfd, 0xfe, 0x9a, 0x76, 0x5e,
	0x75, 0xe5, 0x98, 0xc7, 0xbc, 0xfb, 0x09, 0x00, 0x00, 0xff, 0xff, 0xe6, 0x4e, 0xd4, 0x3a, 0x07,
	0x02, 0x00, 0x00,
}
