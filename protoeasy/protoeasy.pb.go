// Code generated by protoc-gen-go.
// source: protoeasy.proto
// DO NOT EDIT!

/*
Package protoeasy is a generated protocol buffer package.

It is generated from these files:
	protoeasy.proto

It has these top-level messages:
	CompileOptions
	Command
	CompileInfo
	CompileRequest
	CompileResponse
*/
package protoeasy

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"
import google_protobuf "github.com/golang/protobuf/ptypes/duration"

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

type GoPluginType int32

const (
	GoPluginType_GO_PLUGIN_TYPE_NONE   GoPluginType = 0
	GoPluginType_GO_PLUGIN_TYPE_GO     GoPluginType = 1
	GoPluginType_GO_PLUGIN_TYPE_GOFAST GoPluginType = 2
)

var GoPluginType_name = map[int32]string{
	0: "GO_PLUGIN_TYPE_NONE",
	1: "GO_PLUGIN_TYPE_GO",
	2: "GO_PLUGIN_TYPE_GOFAST",
}
var GoPluginType_value = map[string]int32{
	"GO_PLUGIN_TYPE_NONE":   0,
	"GO_PLUGIN_TYPE_GO":     1,
	"GO_PLUGIN_TYPE_GOFAST": 2,
}

func (x GoPluginType) String() string {
	return proto.EnumName(GoPluginType_name, int32(x))
}
func (GoPluginType) EnumDescriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

type GogoPluginType int32

const (
	GogoPluginType_GOGO_PLUGIN_TYPE_NONE       GogoPluginType = 0
	GogoPluginType_GOGO_PLUGIN_TYPE_GOGO       GogoPluginType = 1
	GogoPluginType_GOGO_PLUGIN_TYPE_GOGOFAST   GogoPluginType = 2
	GogoPluginType_GOGO_PLUGIN_TYPE_GOGOFASTER GogoPluginType = 3
	GogoPluginType_GOGO_PLUGIN_TYPE_GOGOSLICK  GogoPluginType = 4
)

var GogoPluginType_name = map[int32]string{
	0: "GOGO_PLUGIN_TYPE_NONE",
	1: "GOGO_PLUGIN_TYPE_GOGO",
	2: "GOGO_PLUGIN_TYPE_GOGOFAST",
	3: "GOGO_PLUGIN_TYPE_GOGOFASTER",
	4: "GOGO_PLUGIN_TYPE_GOGOSLICK",
}
var GogoPluginType_value = map[string]int32{
	"GOGO_PLUGIN_TYPE_NONE":       0,
	"GOGO_PLUGIN_TYPE_GOGO":       1,
	"GOGO_PLUGIN_TYPE_GOGOFAST":   2,
	"GOGO_PLUGIN_TYPE_GOGOFASTER": 3,
	"GOGO_PLUGIN_TYPE_GOGOSLICK":  4,
}

func (x GogoPluginType) String() string {
	return proto.EnumName(GogoPluginType_name, int32(x))
}
func (GogoPluginType) EnumDescriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

type CompileOptions struct {
	Grpc                        bool              `protobuf:"varint,1,opt,name=grpc" json:"grpc,omitempty"`
	GrpcGateway                 bool              `protobuf:"varint,2,opt,name=grpc_gateway,json=grpcGateway" json:"grpc_gateway,omitempty"`
	NoDefaultIncludes           bool              `protobuf:"varint,3,opt,name=no_default_includes,json=noDefaultIncludes" json:"no_default_includes,omitempty"`
	ExcludePattern              []string          `protobuf:"bytes,4,rep,name=exclude_pattern,json=excludePattern" json:"exclude_pattern,omitempty"`
	RelContext                  string            `protobuf:"bytes,5,opt,name=rel_context,json=relContext" json:"rel_context,omitempty"`
	Cpp                         bool              `protobuf:"varint,20,opt,name=cpp" json:"cpp,omitempty"`
	CppRelOut                   string            `protobuf:"bytes,21,opt,name=cpp_rel_out,json=cppRelOut" json:"cpp_rel_out,omitempty"`
	Csharp                      bool              `protobuf:"varint,30,opt,name=csharp" json:"csharp,omitempty"`
	CsharpRelOut                string            `protobuf:"bytes,31,opt,name=csharp_rel_out,json=csharpRelOut" json:"csharp_rel_out,omitempty"`
	Go                          bool              `protobuf:"varint,40,opt,name=go" json:"go,omitempty"`
	GoPluginType                GoPluginType      `protobuf:"varint,41,opt,name=go_plugin_type,json=goPluginType,enum=protoeasy.GoPluginType" json:"go_plugin_type,omitempty"`
	GoRelOut                    string            `protobuf:"bytes,42,opt,name=go_rel_out,json=goRelOut" json:"go_rel_out,omitempty"`
	GoImportPath                string            `protobuf:"bytes,43,opt,name=go_import_path,json=goImportPath" json:"go_import_path,omitempty"`
	GoNoDefaultModifiers        bool              `protobuf:"varint,44,opt,name=go_no_default_modifiers,json=goNoDefaultModifiers" json:"go_no_default_modifiers,omitempty"`
	GoModifiers                 map[string]string `protobuf:"bytes,45,rep,name=go_modifiers,json=goModifiers" json:"go_modifiers,omitempty" protobuf_key:"bytes,1,opt,name=key" protobuf_val:"bytes,2,opt,name=value"`
	Gogo                        bool              `protobuf:"varint,50,opt,name=gogo" json:"gogo,omitempty"`
	GogoPluginType              GogoPluginType    `protobuf:"varint,51,opt,name=gogo_plugin_type,json=gogoPluginType,enum=protoeasy.GogoPluginType" json:"gogo_plugin_type,omitempty"`
	GogoRelOut                  string            `protobuf:"bytes,52,opt,name=gogo_rel_out,json=gogoRelOut" json:"gogo_rel_out,omitempty"`
	GogoImportPath              string            `protobuf:"bytes,53,opt,name=gogo_import_path,json=gogoImportPath" json:"gogo_import_path,omitempty"`
	GogoNoDefaultModifiers      bool              `protobuf:"varint,54,opt,name=gogo_no_default_modifiers,json=gogoNoDefaultModifiers" json:"gogo_no_default_modifiers,omitempty"`
	GogoModifiers               map[string]string `protobuf:"bytes,55,rep,name=gogo_modifiers,json=gogoModifiers" json:"gogo_modifiers,omitempty" protobuf_key:"bytes,1,opt,name=key" protobuf_val:"bytes,2,opt,name=value"`
	Objc                        bool              `protobuf:"varint,60,opt,name=objc" json:"objc,omitempty"`
	ObjcRelOut                  string            `protobuf:"bytes,61,opt,name=objc_rel_out,json=objcRelOut" json:"objc_rel_out,omitempty"`
	Python                      bool              `protobuf:"varint,70,opt,name=python" json:"python,omitempty"`
	PythonRelOut                string            `protobuf:"bytes,71,opt,name=python_rel_out,json=pythonRelOut" json:"python_rel_out,omitempty"`
	Ruby                        bool              `protobuf:"varint,80,opt,name=ruby" json:"ruby,omitempty"`
	RubyRelOut                  string            `protobuf:"bytes,81,opt,name=ruby_rel_out,json=rubyRelOut" json:"ruby_rel_out,omitempty"`
	DescriptorSet               bool              `protobuf:"varint,90,opt,name=descriptor_set,json=descriptorSet" json:"descriptor_set,omitempty"`
	DescriptorSetRelOut         string            `protobuf:"bytes,91,opt,name=descriptor_set_rel_out,json=descriptorSetRelOut" json:"descriptor_set_rel_out,omitempty"`
	DescriptorSetFileName       string            `protobuf:"bytes,92,opt,name=descriptor_set_file_name,json=descriptorSetFileName" json:"descriptor_set_file_name,omitempty"`
	DescriptorSetIncludeImports bool              `protobuf:"varint,93,opt,name=descriptor_set_include_imports,json=descriptorSetIncludeImports" json:"descriptor_set_include_imports,omitempty"`
	Letmegrpc                   bool              `protobuf:"varint,100,opt,name=letmegrpc" json:"letmegrpc,omitempty"`
	LetmegrpcRelOut             string            `protobuf:"bytes,101,opt,name=letmegrpc_rel_out,json=letmegrpcRelOut" json:"letmegrpc_rel_out,omitempty"`
	LetmegrpcImportPath         string            `protobuf:"bytes,102,opt,name=letmegrpc_import_path,json=letmegrpcImportPath" json:"letmegrpc_import_path,omitempty"`
	LetmegrpcNoDefaultModifiers bool              `protobuf:"varint,103,opt,name=letmegrpc_no_default_modifiers,json=letmegrpcNoDefaultModifiers" json:"letmegrpc_no_default_modifiers,omitempty"`
	LetmegrpcModifiers          map[string]string `protobuf:"bytes,104,rep,name=letmegrpc_modifiers,json=letmegrpcModifiers" json:"letmegrpc_modifiers,omitempty" protobuf_key:"bytes,1,opt,name=key" protobuf_val:"bytes,2,opt,name=value"`
	OperatorCmd                 bool              `protobuf:"varint,110,opt,name=operator_cmd,json=operatorCmd" json:"operator_cmd,omitempty"`
	OperatorCmdOut              string            `protobuf:"bytes,111,opt,name=operator_cmd_out,json=operatorCmdOut" json:"operator_cmd_out,omitempty"`
	OperatorHubot               bool              `protobuf:"varint,120,opt,name=operator_hubot,json=operatorHubot" json:"operator_hubot,omitempty"`
	OperatorHubotOut            string            `protobuf:"bytes,121,opt,name=operator_hubot_out,json=operatorHubotOut" json:"operator_hubot_out,omitempty"`
	OperatorLocal               bool              `protobuf:"varint,130,opt,name=operator_local,json=operatorLocal" json:"operator_local,omitempty"`
	OperatorLocalOut            string            `protobuf:"bytes,131,opt,name=operator_local_out,json=operatorLocalOut" json:"operator_local_out,omitempty"`
	OperatorServer              bool              `protobuf:"varint,140,opt,name=operator_server,json=operatorServer" json:"operator_server,omitempty"`
	OperatorServerOut           string            `protobuf:"bytes,141,opt,name=operator_server_out,json=operatorServerOut" json:"operator_server_out,omitempty"`
}

func (m *CompileOptions) Reset()                    { *m = CompileOptions{} }
func (m *CompileOptions) String() string            { return proto.CompactTextString(m) }
func (*CompileOptions) ProtoMessage()               {}
func (*CompileOptions) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

func (m *CompileOptions) GetGoModifiers() map[string]string {
	if m != nil {
		return m.GoModifiers
	}
	return nil
}

func (m *CompileOptions) GetGogoModifiers() map[string]string {
	if m != nil {
		return m.GogoModifiers
	}
	return nil
}

func (m *CompileOptions) GetLetmegrpcModifiers() map[string]string {
	if m != nil {
		return m.LetmegrpcModifiers
	}
	return nil
}

type Command struct {
	Arg []string `protobuf:"bytes,1,rep,name=arg" json:"arg,omitempty"`
}

func (m *Command) Reset()                    { *m = Command{} }
func (m *Command) String() string            { return proto.CompactTextString(m) }
func (*Command) ProtoMessage()               {}
func (*Command) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

type CompileInfo struct {
	Command         []*Command                `protobuf:"bytes,1,rep,name=command" json:"command,omitempty"`
	InputSizeBytes  uint64                    `protobuf:"varint,2,opt,name=input_size_bytes,json=inputSizeBytes" json:"input_size_bytes,omitempty"`
	OutputSizeBytes uint64                    `protobuf:"varint,3,opt,name=output_size_bytes,json=outputSizeBytes" json:"output_size_bytes,omitempty"`
	Duration        *google_protobuf.Duration `protobuf:"bytes,4,opt,name=duration" json:"duration,omitempty"`
}

func (m *CompileInfo) Reset()                    { *m = CompileInfo{} }
func (m *CompileInfo) String() string            { return proto.CompactTextString(m) }
func (*CompileInfo) ProtoMessage()               {}
func (*CompileInfo) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{2} }

func (m *CompileInfo) GetCommand() []*Command {
	if m != nil {
		return m.Command
	}
	return nil
}

func (m *CompileInfo) GetDuration() *google_protobuf.Duration {
	if m != nil {
		return m.Duration
	}
	return nil
}

type CompileRequest struct {
	Tar            []byte          `protobuf:"bytes,1,opt,name=tar,proto3" json:"tar,omitempty"`
	CompileOptions *CompileOptions `protobuf:"bytes,2,opt,name=compile_options,json=compileOptions" json:"compile_options,omitempty"`
}

func (m *CompileRequest) Reset()                    { *m = CompileRequest{} }
func (m *CompileRequest) String() string            { return proto.CompactTextString(m) }
func (*CompileRequest) ProtoMessage()               {}
func (*CompileRequest) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{3} }

func (m *CompileRequest) GetCompileOptions() *CompileOptions {
	if m != nil {
		return m.CompileOptions
	}
	return nil
}

type CompileResponse struct {
	Tar         []byte       `protobuf:"bytes,1,opt,name=tar,proto3" json:"tar,omitempty"`
	CompileInfo *CompileInfo `protobuf:"bytes,2,opt,name=compile_info,json=compileInfo" json:"compile_info,omitempty"`
}

func (m *CompileResponse) Reset()                    { *m = CompileResponse{} }
func (m *CompileResponse) String() string            { return proto.CompactTextString(m) }
func (*CompileResponse) ProtoMessage()               {}
func (*CompileResponse) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{4} }

func (m *CompileResponse) GetCompileInfo() *CompileInfo {
	if m != nil {
		return m.CompileInfo
	}
	return nil
}

func init() {
	proto.RegisterType((*CompileOptions)(nil), "protoeasy.CompileOptions")
	proto.RegisterType((*Command)(nil), "protoeasy.Command")
	proto.RegisterType((*CompileInfo)(nil), "protoeasy.CompileInfo")
	proto.RegisterType((*CompileRequest)(nil), "protoeasy.CompileRequest")
	proto.RegisterType((*CompileResponse)(nil), "protoeasy.CompileResponse")
	proto.RegisterEnum("protoeasy.GoPluginType", GoPluginType_name, GoPluginType_value)
	proto.RegisterEnum("protoeasy.GogoPluginType", GogoPluginType_name, GogoPluginType_value)
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConn

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion2

// Client API for API service

type APIClient interface {
	Compile(ctx context.Context, in *CompileRequest, opts ...grpc.CallOption) (*CompileResponse, error)
}

type aPIClient struct {
	cc *grpc.ClientConn
}

func NewAPIClient(cc *grpc.ClientConn) APIClient {
	return &aPIClient{cc}
}

func (c *aPIClient) Compile(ctx context.Context, in *CompileRequest, opts ...grpc.CallOption) (*CompileResponse, error) {
	out := new(CompileResponse)
	err := grpc.Invoke(ctx, "/protoeasy.API/Compile", in, out, c.cc, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for API service

type APIServer interface {
	Compile(context.Context, *CompileRequest) (*CompileResponse, error)
}

func RegisterAPIServer(s *grpc.Server, srv APIServer) {
	s.RegisterService(&_API_serviceDesc, srv)
}

func _API_Compile_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(CompileRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(APIServer).Compile(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/protoeasy.API/Compile",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(APIServer).Compile(ctx, req.(*CompileRequest))
	}
	return interceptor(ctx, in, info, handler)
}

var _API_serviceDesc = grpc.ServiceDesc{
	ServiceName: "protoeasy.API",
	HandlerType: (*APIServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Compile",
			Handler:    _API_Compile_Handler,
		},
	},
	Streams: []grpc.StreamDesc{},
}

var fileDescriptor0 = []byte{
	// 1201 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0x94, 0x56, 0x5d, 0x77, 0xdb, 0x44,
	0x13, 0xae, 0xe3, 0xb4, 0x89, 0xc7, 0xae, 0xed, 0x6c, 0xbe, 0x36, 0xce, 0xfb, 0xa6, 0xc1, 0xa7,
	0x40, 0x08, 0xa9, 0x73, 0x70, 0x08, 0xa5, 0x1c, 0xca, 0xa1, 0x4d, 0x13, 0xe3, 0x43, 0x9a, 0x18,
	0x39, 0x5c, 0x94, 0x2f, 0x1d, 0x59, 0x5e, 0xcb, 0x06, 0x59, 0x2b, 0xf4, 0x51, 0x62, 0x2e, 0xe1,
	0x16, 0xfe, 0x06, 0x7f, 0x05, 0x7e, 0x16, 0xbb, 0xb3, 0xb2, 0x2c, 0x39, 0x0a, 0xe7, 0xf4, 0x4a,
	0xb3, 0xcf, 0x3c, 0x33, 0xb3, 0xfb, 0xec, 0xac, 0x76, 0xa1, 0xe2, 0x7a, 0x3c, 0xe0, 0xcc, 0xf0,
	0x27, 0x0d, 0xb4, 0x48, 0x21, 0x06, 0x6a, 0x3b, 0x16, 0xe7, 0x96, 0xcd, 0x0e, 0x11, 0xe9, 0x85,
	0x83, 0xc3, 0x7e, 0xe8, 0x19, 0xc1, 0x88, 0x3b, 0x8a, 0x5a, 0xff, 0xbb, 0x0a, 0xe5, 0x13, 0x3e,
	0x76, 0x47, 0x36, 0xbb, 0x74, 0x25, 0xee, 0x13, 0x02, 0x8b, 0x96, 0xe7, 0x9a, 0x34, 0xb7, 0x9b,
	0xdb, 0x5b, 0xd6, 0xd0, 0x26, 0x6f, 0x41, 0x49, 0x7e, 0x75, 0xcb, 0x08, 0xd8, 0x2f, 0xc6, 0x84,
	0x2e, 0xa0, 0xaf, 0x28, 0xb1, 0x96, 0x82, 0x48, 0x03, 0x56, 0x1d, 0xae, 0xf7, 0xd9, 0xc0, 0x08,
	0xed, 0x40, 0x1f, 0x39, 0xa6, 0x1d, 0xf6, 0x99, 0x4f, 0xf3, 0xc8, 0x5c, 0x71, 0xf8, 0x0b, 0xe5,
	0x69, 0x47, 0x0e, 0xf2, 0x2e, 0x54, 0xd8, 0x35, 0xda, 0xba, 0x6b, 0x04, 0x01, 0xf3, 0x1c, 0xba,
	0xb8, 0x9b, 0xdf, 0x2b, 0x68, 0xe5, 0x08, 0xee, 0x28, 0x94, 0x3c, 0x80, 0xa2, 0xc7, 0x6c, 0xdd,
	0xe4, 0x4e, 0xc0, 0xae, 0x03, 0x7a, 0x57, 0x24, 0x2c, 0x68, 0x20, 0xa0, 0x13, 0x85, 0x90, 0x2a,
	0xe4, 0x4d, 0xd7, 0xa5, 0x6b, 0x58, 0x49, 0x9a, 0x64, 0x07, 0x8a, 0xe2, 0xa3, 0xcb, 0x30, 0x1e,
	0x06, 0x74, 0x1d, 0x43, 0x0a, 0x02, 0xd2, 0x98, 0x7d, 0x19, 0x06, 0x64, 0x03, 0xee, 0x99, 0xfe,
	0xd0, 0xf0, 0x5c, 0xba, 0x83, 0x41, 0xd1, 0x88, 0x3c, 0x84, 0xb2, 0xb2, 0xe2, 0xd0, 0x07, 0x18,
	0x5a, 0x52, 0x68, 0x14, 0x5d, 0x86, 0x05, 0x8b, 0xd3, 0x3d, 0x8c, 0x14, 0x16, 0x79, 0x0a, 0x65,
	0x8b, 0xeb, 0xae, 0x1d, 0x5a, 0x23, 0x47, 0x0f, 0x26, 0x2e, 0xa3, 0xef, 0x09, 0x5f, 0xb9, 0xb9,
	0xd9, 0x98, 0x6d, 0x4c, 0x8b, 0x77, 0xd0, 0x7f, 0x25, 0xdc, 0x5a, 0xc9, 0x4a, 0x8c, 0xc8, 0xff,
	0x00, 0x44, 0xf8, 0xb4, 0xe0, 0x3e, 0x16, 0x5c, 0xb6, 0x78, 0x54, 0xec, 0x21, 0x26, 0x1f, 0x8d,
	0x5d, 0xee, 0x05, 0x52, 0xa8, 0x21, 0x7d, 0x5f, 0x4d, 0xc9, 0xe2, 0x6d, 0x04, 0x85, 0x4c, 0x43,
	0x72, 0x0c, 0x9b, 0x82, 0x95, 0xd0, 0x7f, 0xcc, 0xfb, 0xa3, 0xc1, 0x88, 0x79, 0x3e, 0x3d, 0xc0,
	0x79, 0xae, 0x59, 0xfc, 0x62, 0xba, 0x05, 0x2f, 0xa7, 0x3e, 0xf2, 0x52, 0x6c, 0x2b, 0x4f, 0x70,
	0x1f, 0x89, 0x0d, 0x28, 0x36, 0xf7, 0x13, 0xf3, 0x4e, 0xf7, 0x86, 0x58, 0x46, 0x1c, 0x7c, 0xea,
	0x04, 0xde, 0x44, 0xb4, 0xc0, 0x0c, 0xc1, 0xce, 0xe1, 0x42, 0x9a, 0x66, 0xd4, 0x39, 0xc2, 0x26,
	0x27, 0x50, 0x95, 0xdf, 0x94, 0x3c, 0x47, 0x28, 0xcf, 0x56, 0x4a, 0x9e, 0xa4, 0x24, 0x5a, 0xd9,
	0x4a, 0x8d, 0xc9, 0xae, 0x9c, 0x67, 0x42, 0xa4, 0x0f, 0x55, 0x0f, 0x48, 0x2c, 0x92, 0x69, 0x2f,
	0x2a, 0x93, 0x14, 0xea, 0x18, 0x59, 0x98, 0x2b, 0x21, 0xd5, 0x13, 0xd8, 0x42, 0x66, 0xa6, 0x58,
	0x1f, 0xe1, 0xcc, 0x37, 0x24, 0x21, 0x43, 0xae, 0x2e, 0x60, 0xb2, 0x04, 0xff, 0x31, 0x0a, 0x76,
	0xf0, 0x5f, 0x82, 0x59, 0xf3, 0x92, 0xdd, 0xb7, 0xf8, 0x9c, 0x68, 0xbc, 0xf7, 0xa3, 0x49, 0x3f,
	0x55, 0xa2, 0x49, 0x5b, 0xae, 0x57, 0x7e, 0xe3, 0xf5, 0x3e, 0x55, 0xeb, 0x95, 0xd8, 0xac, 0x83,
	0xdd, 0x49, 0x30, 0xe4, 0x0e, 0x3d, 0x53, 0x1d, 0xac, 0x46, 0xb2, 0x5d, 0x94, 0x15, 0xc7, 0xb6,
	0x54, 0xbb, 0x28, 0x34, 0x8a, 0x16, 0x35, 0xbd, 0xb0, 0x37, 0xa1, 0x1d, 0x55, 0x53, 0xda, 0xb2,
	0xa6, 0xfc, 0xc6, 0x71, 0x5f, 0x45, 0xe7, 0x4c, 0x60, 0x51, 0xd4, 0xdb, 0x50, 0x16, 0x07, 0xd7,
	0xf4, 0x46, 0x6e, 0xc0, 0x3d, 0xdd, 0x67, 0x01, 0xfd, 0x06, 0xe3, 0xef, 0xcf, 0xd0, 0x2e, 0x0b,
	0xc8, 0x11, 0x6c, 0xa4, 0x69, 0x71, 0xca, 0x6f, 0x31, 0xe5, 0x6a, 0x8a, 0x1e, 0xe5, 0x7e, 0x0c,
	0x74, 0x2e, 0x68, 0x20, 0x54, 0xd4, 0x1d, 0x63, 0xcc, 0xe8, 0x77, 0x18, 0xb6, 0x9e, 0x0a, 0x3b,
	0x13, 0xde, 0x0b, 0xe1, 0x14, 0xfd, 0xb5, 0x33, 0x17, 0x18, 0xfd, 0x7a, 0xa2, 0x56, 0xf0, 0xe9,
	0xf7, 0x38, 0xc9, 0xed, 0x54, 0x78, 0xf4, 0x17, 0x52, 0x6d, 0xe1, 0x8b, 0x23, 0x58, 0xb0, 0x59,
	0x30, 0x66, 0xf8, 0xdf, 0xeb, 0x23, 0x7f, 0x06, 0x90, 0x7d, 0x58, 0x89, 0x07, 0xf1, 0x5a, 0x18,
	0x4e, 0xaa, 0x12, 0x3b, 0xa2, 0x75, 0x34, 0x61, 0x7d, 0xc6, 0x4d, 0x36, 0xe3, 0x40, 0xad, 0x3d,
	0x76, 0x26, 0x3a, 0x52, 0x2c, 0x61, 0x16, 0x93, 0xd9, 0x96, 0x96, 0x5a, 0x42, 0xcc, 0xca, 0xe8,
	0xcd, 0x1e, 0xcc, 0x72, 0x27, 0x22, 0x87, 0xd8, 0xa0, 0x1f, 0xdc, 0xde, 0xa0, 0xe7, 0xd3, 0xa0,
	0xb9, 0x2e, 0x25, 0xf6, 0x0d, 0x87, 0xbc, 0x05, 0xb8, 0xcb, 0xc4, 0xfd, 0x21, 0x94, 0x36, 0xc7,
	0x7d, 0xea, 0xa8, 0x5b, 0x60, 0x8a, 0x9d, 0x8c, 0xfb, 0xf2, 0x1c, 0x26, 0x29, 0x28, 0x15, 0x57,
	0xe7, 0x30, 0x41, 0x8b, 0xba, 0x29, 0x66, 0x0e, 0xc3, 0x1e, 0x0f, 0xe8, 0xb5, 0xea, 0xa6, 0x29,
	0xfa, 0x85, 0x04, 0xc9, 0x01, 0x90, 0x34, 0x0d, 0x53, 0x4e, 0x30, 0x65, 0x35, 0x45, 0x95, 0x49,
	0xdf, 0x49, 0x24, 0xb5, 0xb9, 0x69, 0xd8, 0xf4, 0xb7, 0x5c, 0x3a, 0xeb, 0xb9, 0x44, 0xc9, 0xa3,
	0x44, 0x56, 0xe4, 0x61, 0xd6, 0xdf, 0x73, 0xe9, 0xb4, 0xc8, 0x55, 0x7f, 0x97, 0x4a, 0x4c, 0xf7,
	0x99, 0xf7, 0x9a, 0x79, 0xf4, 0x0f, 0x95, 0x37, 0x2e, 0xd7, 0x45, 0x98, 0x1c, 0xc2, 0xea, 0x1c,
	0x13, 0x33, 0xff, 0xa9, 0x32, 0xaf, 0xa4, 0xd9, 0x22, 0x75, 0xed, 0x33, 0xa8, 0xce, 0xff, 0x54,
	0xe5, 0x85, 0xf6, 0x13, 0x9b, 0x50, 0x15, 0x23, 0x4d, 0xb2, 0x06, 0x77, 0x5f, 0x1b, 0x76, 0xc8,
	0xf0, 0xe2, 0x2d, 0x68, 0x6a, 0xf0, 0xc9, 0xc2, 0xc7, 0xb9, 0xda, 0xe7, 0x40, 0x6e, 0xfe, 0x63,
	0xde, 0x28, 0xc3, 0x29, 0x6c, 0xde, 0xd2, 0x04, 0x6f, 0x92, 0xa6, 0xbe, 0x0d, 0x4b, 0xa2, 0xb5,
	0xc6, 0x86, 0xd3, 0x97, 0x61, 0x86, 0x67, 0x89, 0x30, 0x79, 0x9d, 0x4b, 0xb3, 0xfe, 0x4f, 0x0e,
	0x8a, 0x51, 0xe3, 0xb5, 0x9d, 0x01, 0x17, 0xbb, 0xba, 0x64, 0x2a, 0x32, 0xb2, 0x8a, 0x4d, 0x92,
	0xee, 0x50, 0xe9, 0xd1, 0xa6, 0x14, 0xd9, 0x54, 0x23, 0xc7, 0x0d, 0x03, 0xdd, 0x1f, 0xfd, 0xca,
	0xf4, 0xde, 0x24, 0x10, 0xef, 0x0a, 0x59, 0x7f, 0x51, 0x2b, 0x23, 0xde, 0x15, 0xf0, 0x73, 0x89,
	0xca, 0xa3, 0x2a, 0xe4, 0x9e, 0xa3, 0xe6, 0x91, 0x5a, 0x51, 0x8e, 0x19, 0xf7, 0x18, 0x96, 0xa7,
	0x8f, 0x21, 0xf1, 0xf2, 0xc8, 0x89, 0x49, 0x6c, 0x35, 0xd4, 0x6b, 0xa9, 0x31, 0x7d, 0x2d, 0x35,
	0x5e, 0x44, 0x04, 0x2d, 0xa6, 0xd6, 0x07, 0xf1, 0x83, 0x49, 0x63, 0x3f, 0x87, 0xcc, 0xc7, 0xf7,
	0x47, 0x60, 0x78, 0xa8, 0x52, 0x49, 0x93, 0x26, 0x79, 0x0e, 0x15, 0x53, 0x71, 0x74, 0xae, 0xce,
	0x19, 0xce, 0xb7, 0x98, 0xba, 0xf3, 0xd2, 0x07, 0x51, 0x2b, 0x9b, 0xa9, 0x71, 0xfd, 0x07, 0xa8,
	0xc4, 0x75, 0x7c, 0x57, 0x20, 0x2c, 0xa3, 0xd0, 0x13, 0x28, 0x4d, 0x0b, 0x8d, 0x84, 0xae, 0x51,
	0x95, 0x8d, 0x9b, 0x55, 0xa4, 0xea, 0x5a, 0xd1, 0x9c, 0x0d, 0xf6, 0x5f, 0x41, 0x29, 0xf9, 0x28,
	0x21, 0x9b, 0xb0, 0xda, 0xba, 0xd4, 0x3b, 0xe7, 0x5f, 0xb7, 0xda, 0x17, 0xfa, 0xd5, 0xab, 0xce,
	0xa9, 0x7e, 0x71, 0x79, 0x71, 0x5a, 0xbd, 0x43, 0xd6, 0x61, 0x65, 0xce, 0xd1, 0xba, 0xac, 0xe6,
	0xc8, 0x16, 0xac, 0xdf, 0x80, 0xcf, 0x9e, 0x75, 0xaf, 0xaa, 0x0b, 0xfb, 0x7f, 0xe5, 0xa0, 0x9c,
	0xbe, 0xd1, 0x15, 0x3b, 0x3b, 0x7f, 0x96, 0x4b, 0x02, 0xa2, 0xc6, 0xff, 0x61, 0x2b, 0xd3, 0xa5,
	0xea, 0x88, 0x97, 0xe1, 0xf6, 0xad, 0xee, 0x53, 0xad, 0x9a, 0x17, 0xef, 0xc0, 0x5a, 0x26, 0xa1,
	0x7b, 0xde, 0x3e, 0xf9, 0xb2, 0xba, 0xd8, 0x6c, 0x43, 0xfe, 0x59, 0xa7, 0x2d, 0xb6, 0x6b, 0x29,
	0x92, 0x89, 0x64, 0x6c, 0x50, 0xb4, 0xcd, 0xb5, 0x5a, 0x96, 0x4b, 0xed, 0x4c, 0xfd, 0x4e, 0xef,
	0x1e, 0x3a, 0x8f, 0xfe, 0x0d, 0x00, 0x00, 0xff, 0xff, 0x9a, 0x05, 0x95, 0xbd, 0x8d, 0x0b, 0x00,
	0x00,
}