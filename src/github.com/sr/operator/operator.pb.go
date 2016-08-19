// Code generated by protoc-gen-go.
// source: operator.proto
// DO NOT EDIT!

/*
Package operator is a generated protocol buffer package.

It is generated from these files:
	operator.proto

It has these top-level messages:
	Request
	Call
	Error
	Source
	Room
	User
	Message
	Output
	ServerStartupNotice
	Service
	ServerStartupError
	ServiceRegistered
	ServiceStartupError
*/
package operator

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"
import google_protobuf "github.com/golang/protobuf/protoc-gen-go/descriptor"
import google_protobuf1 "github.com/golang/protobuf/ptypes/duration"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// This is a compile-time assertion to ensure that this generated file
// is compatible with the proto package it is being compiled against.
const _ = proto.ProtoPackageIsVersion1

type SourceType int32

const (
	SourceType_HUBOT   SourceType = 0
	SourceType_COMMAND SourceType = 1
)

var SourceType_name = map[int32]string{
	0: "HUBOT",
	1: "COMMAND",
}
var SourceType_value = map[string]int32{
	"HUBOT":   0,
	"COMMAND": 1,
}

func (x SourceType) String() string {
	return proto.EnumName(SourceType_name, int32(x))
}
func (SourceType) EnumDescriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

type Request struct {
	Source *Source `protobuf:"bytes,1,opt,name=source" json:"source,omitempty"`
	Call   *Call   `protobuf:"bytes,2,opt,name=call" json:"call,omitempty"`
}

func (m *Request) Reset()                    { *m = Request{} }
func (m *Request) String() string            { return proto.CompactTextString(m) }
func (*Request) ProtoMessage()               {}
func (*Request) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{0} }

func (m *Request) GetSource() *Source {
	if m != nil {
		return m.Source
	}
	return nil
}

func (m *Request) GetCall() *Call {
	if m != nil {
		return m.Call
	}
	return nil
}

// Call represents a completed gRPC call. The Error field will be non-nil if
// it resulted in an error.
type Call struct {
	Service  string                     `protobuf:"bytes,1,opt,name=service" json:"service,omitempty"`
	Method   string                     `protobuf:"bytes,2,opt,name=method" json:"method,omitempty"`
	Error    *Error                     `protobuf:"bytes,5,opt,name=error" json:"error,omitempty"`
	Duration *google_protobuf1.Duration `protobuf:"bytes,6,opt,name=duration" json:"duration,omitempty"`
}

func (m *Call) Reset()                    { *m = Call{} }
func (m *Call) String() string            { return proto.CompactTextString(m) }
func (*Call) ProtoMessage()               {}
func (*Call) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

func (m *Call) GetError() *Error {
	if m != nil {
		return m.Error
	}
	return nil
}

func (m *Call) GetDuration() *google_protobuf1.Duration {
	if m != nil {
		return m.Duration
	}
	return nil
}

type Error struct {
	Message string `protobuf:"bytes,1,opt,name=message" json:"message,omitempty"`
}

func (m *Error) Reset()                    { *m = Error{} }
func (m *Error) String() string            { return proto.CompactTextString(m) }
func (*Error) ProtoMessage()               {}
func (*Error) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{2} }

type Source struct {
	Type     SourceType `protobuf:"varint,1,opt,name=type,enum=operator.SourceType" json:"type,omitempty"`
	User     *User      `protobuf:"bytes,2,opt,name=user" json:"user,omitempty"`
	Room     *Room      `protobuf:"bytes,3,opt,name=room" json:"room,omitempty"`
	Hostname string     `protobuf:"bytes,4,opt,name=hostname" json:"hostname,omitempty"`
}

func (m *Source) Reset()                    { *m = Source{} }
func (m *Source) String() string            { return proto.CompactTextString(m) }
func (*Source) ProtoMessage()               {}
func (*Source) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{3} }

func (m *Source) GetUser() *User {
	if m != nil {
		return m.User
	}
	return nil
}

func (m *Source) GetRoom() *Room {
	if m != nil {
		return m.Room
	}
	return nil
}

type Room struct {
	Name string `protobuf:"bytes,1,opt,name=name" json:"name,omitempty"`
}

func (m *Room) Reset()                    { *m = Room{} }
func (m *Room) String() string            { return proto.CompactTextString(m) }
func (*Room) ProtoMessage()               {}
func (*Room) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{4} }

type User struct {
	Id       string `protobuf:"bytes,1,opt,name=id" json:"id,omitempty"`
	Login    string `protobuf:"bytes,2,opt,name=login" json:"login,omitempty"`
	RealName string `protobuf:"bytes,3,opt,name=real_name,json=realName" json:"real_name,omitempty"`
	Email    string `protobuf:"bytes,4,opt,name=email" json:"email,omitempty"`
}

func (m *User) Reset()                    { *m = User{} }
func (m *User) String() string            { return proto.CompactTextString(m) }
func (*User) ProtoMessage()               {}
func (*User) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{5} }

type Message struct {
	Source *Source `protobuf:"bytes,1,opt,name=source" json:"source,omitempty"`
	Text   string  `protobuf:"bytes,2,opt,name=text" json:"text,omitempty"`
}

func (m *Message) Reset()                    { *m = Message{} }
func (m *Message) String() string            { return proto.CompactTextString(m) }
func (*Message) ProtoMessage()               {}
func (*Message) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{6} }

func (m *Message) GetSource() *Source {
	if m != nil {
		return m.Source
	}
	return nil
}

type Output struct {
	PlainText string `protobuf:"bytes,1,opt,name=PlainText,json=plainText" json:"PlainText,omitempty"`
}

func (m *Output) Reset()                    { *m = Output{} }
func (m *Output) String() string            { return proto.CompactTextString(m) }
func (*Output) ProtoMessage()               {}
func (*Output) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{7} }

type ServerStartupNotice struct {
	Address  string     `protobuf:"bytes,1,opt,name=Address,json=address" json:"Address,omitempty"`
	Protocol string     `protobuf:"bytes,2,opt,name=Protocol,json=protocol" json:"Protocol,omitempty"`
	Services []*Service `protobuf:"bytes,3,rep,name=services" json:"services,omitempty"`
}

func (m *ServerStartupNotice) Reset()                    { *m = ServerStartupNotice{} }
func (m *ServerStartupNotice) String() string            { return proto.CompactTextString(m) }
func (*ServerStartupNotice) ProtoMessage()               {}
func (*ServerStartupNotice) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{8} }

func (m *ServerStartupNotice) GetServices() []*Service {
	if m != nil {
		return m.Services
	}
	return nil
}

type Service struct {
	Name string `protobuf:"bytes,1,opt,name=name" json:"name,omitempty"`
}

func (m *Service) Reset()                    { *m = Service{} }
func (m *Service) String() string            { return proto.CompactTextString(m) }
func (*Service) ProtoMessage()               {}
func (*Service) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{9} }

type ServerStartupError struct {
	Message string `protobuf:"bytes,1,opt,name=message" json:"message,omitempty"`
}

func (m *ServerStartupError) Reset()                    { *m = ServerStartupError{} }
func (m *ServerStartupError) String() string            { return proto.CompactTextString(m) }
func (*ServerStartupError) ProtoMessage()               {}
func (*ServerStartupError) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{10} }

type ServiceRegistered struct {
	Service *Service `protobuf:"bytes,1,opt,name=service" json:"service,omitempty"`
}

func (m *ServiceRegistered) Reset()                    { *m = ServiceRegistered{} }
func (m *ServiceRegistered) String() string            { return proto.CompactTextString(m) }
func (*ServiceRegistered) ProtoMessage()               {}
func (*ServiceRegistered) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{11} }

func (m *ServiceRegistered) GetService() *Service {
	if m != nil {
		return m.Service
	}
	return nil
}

type ServiceStartupError struct {
	Service *Service `protobuf:"bytes,1,opt,name=service" json:"service,omitempty"`
	Message string   `protobuf:"bytes,2,opt,name=message" json:"message,omitempty"`
}

func (m *ServiceStartupError) Reset()                    { *m = ServiceStartupError{} }
func (m *ServiceStartupError) String() string            { return proto.CompactTextString(m) }
func (*ServiceStartupError) ProtoMessage()               {}
func (*ServiceStartupError) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{12} }

func (m *ServiceStartupError) GetService() *Service {
	if m != nil {
		return m.Service
	}
	return nil
}

var E_Name = &proto.ExtensionDesc{
	ExtendedType:  (*google_protobuf.ServiceOptions)(nil),
	ExtensionType: (*string)(nil),
	Field:         51234,
	Name:          "operator.name",
	Tag:           "bytes,51234,opt,name=name",
}

func init() {
	proto.RegisterType((*Request)(nil), "operator.Request")
	proto.RegisterType((*Call)(nil), "operator.Call")
	proto.RegisterType((*Error)(nil), "operator.Error")
	proto.RegisterType((*Source)(nil), "operator.Source")
	proto.RegisterType((*Room)(nil), "operator.Room")
	proto.RegisterType((*User)(nil), "operator.User")
	proto.RegisterType((*Message)(nil), "operator.Message")
	proto.RegisterType((*Output)(nil), "operator.Output")
	proto.RegisterType((*ServerStartupNotice)(nil), "operator.ServerStartupNotice")
	proto.RegisterType((*Service)(nil), "operator.Service")
	proto.RegisterType((*ServerStartupError)(nil), "operator.ServerStartupError")
	proto.RegisterType((*ServiceRegistered)(nil), "operator.ServiceRegistered")
	proto.RegisterType((*ServiceStartupError)(nil), "operator.ServiceStartupError")
	proto.RegisterEnum("operator.SourceType", SourceType_name, SourceType_value)
	proto.RegisterExtension(E_Name)
}

var fileDescriptor0 = []byte{
	// 577 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0x94, 0x54, 0xdb, 0x6e, 0xd3, 0x40,
	0x10, 0x25, 0x89, 0xe3, 0xc4, 0x53, 0x29, 0xa4, 0x4b, 0x85, 0x4c, 0xb8, 0x95, 0x15, 0xa0, 0x0a,
	0x84, 0x2b, 0x15, 0xf5, 0x85, 0x27, 0x7a, 0x41, 0xf0, 0x92, 0xa4, 0xda, 0xa4, 0x42, 0x42, 0x48,
	0x95, 0x1b, 0x2f, 0xa9, 0x25, 0x3b, 0x6b, 0x76, 0xd7, 0x08, 0xf8, 0x0a, 0x9e, 0xf8, 0x00, 0xbe,
	0x94, 0xbd, 0xd9, 0x69, 0x9a, 0x4a, 0x55, 0xdf, 0xf6, 0xcc, 0x1c, 0xcf, 0x9c, 0x39, 0x3b, 0x6b,
	0xe8, 0xb1, 0x82, 0xf2, 0x58, 0x32, 0x1e, 0x15, 0x9c, 0x49, 0x86, 0xba, 0x15, 0x1e, 0x6c, 0xcf,
	0x19, 0x9b, 0x67, 0x74, 0xd7, 0xc4, 0xcf, 0xcb, 0x6f, 0xbb, 0x09, 0x15, 0x33, 0x9e, 0x16, 0x35,
	0x77, 0xf0, 0x64, 0x8d, 0x51, 0xaa, 0x4f, 0x53, 0xb6, 0xb0, 0x79, 0xfc, 0x19, 0x3a, 0x84, 0x7e,
	0x2f, 0xa9, 0x90, 0x68, 0x07, 0x7c, 0xc1, 0x4a, 0x3e, 0xa3, 0x61, 0x63, 0xbb, 0xb1, 0xb3, 0xb1,
	0xd7, 0x8f, 0xea, 0xbe, 0x13, 0x13, 0x27, 0x2e, 0x8f, 0x30, 0x78, 0xb3, 0x38, 0xcb, 0xc2, 0xa6,
	0xe1, 0xf5, 0x96, 0xbc, 0x23, 0x15, 0x25, 0x26, 0x87, 0xff, 0x36, 0xc0, 0xd3, 0x10, 0x85, 0xd0,
	0x11, 0x94, 0xff, 0x48, 0x5d, 0xdd, 0x80, 0x54, 0x10, 0xdd, 0x07, 0x3f, 0xa7, 0xf2, 0x82, 0x25,
	0xa6, 0x50, 0x40, 0x1c, 0x42, 0x2f, 0xa0, 0x4d, 0x39, 0x67, 0x3c, 0x6c, 0x9b, 0xfa, 0x77, 0x97,
	0xf5, 0x3f, 0xe8, 0x30, 0xb1, 0x59, 0xb4, 0x0f, 0xdd, 0x6a, 0x98, 0xd0, 0x37, 0xcc, 0x07, 0x91,
	0x9d, 0x36, 0xaa, 0xa6, 0x8d, 0x8e, 0x1d, 0x81, 0xd4, 0x54, 0xfc, 0x0c, 0xda, 0xa6, 0x8c, 0x16,
	0x96, 0x53, 0x21, 0xe2, 0x79, 0x2d, 0xcc, 0x41, 0xad, 0xdd, 0xb7, 0x23, 0x2b, 0x53, 0x3c, 0xf9,
	0xab, 0xb0, 0x8c, 0xde, 0xde, 0xd6, 0x55, 0x4b, 0xa6, 0x2a, 0x47, 0x0c, 0x43, 0x9b, 0x52, 0xaa,
	0xc9, 0xd6, 0x4d, 0x39, 0x55, 0x51, 0x62, 0x72, 0x9a, 0xc3, 0x19, 0xcb, 0xc3, 0xd6, 0x55, 0x0e,
	0x51, 0x51, 0x62, 0x72, 0x68, 0x00, 0xdd, 0x0b, 0x26, 0xe4, 0x22, 0xce, 0x69, 0xe8, 0x19, 0x5d,
	0x35, 0xc6, 0x03, 0xf0, 0x34, 0x13, 0x21, 0xf0, 0x4c, 0xde, 0xea, 0x36, 0x67, 0x7c, 0x06, 0x9e,
	0xee, 0x84, 0x7a, 0xd0, 0x4c, 0x13, 0x97, 0x51, 0x27, 0xb4, 0x05, 0xed, 0x8c, 0xcd, 0xd3, 0x85,
	0x33, 0xd9, 0x02, 0xf4, 0x10, 0x02, 0x4e, 0xe3, 0xec, 0xcc, 0x94, 0x69, 0xd9, 0x36, 0x3a, 0x30,
	0x52, 0x58, 0x7f, 0x42, 0xf3, 0x38, 0xcd, 0x5c, 0x7f, 0x0b, 0xf0, 0x47, 0xe8, 0x0c, 0xad, 0x41,
	0xb7, 0x58, 0x15, 0xa5, 0x54, 0xd2, 0x9f, 0xd2, 0x35, 0x37, 0x67, 0xfc, 0x12, 0xfc, 0x71, 0x29,
	0x8b, 0x52, 0xa2, 0x47, 0x10, 0x9c, 0x64, 0x71, 0xba, 0x98, 0x6a, 0x8a, 0x95, 0x1c, 0x14, 0x55,
	0x00, 0xff, 0x86, 0x7b, 0x13, 0xb5, 0x2a, 0x94, 0x4f, 0x64, 0xcc, 0x65, 0x59, 0x8c, 0x98, 0xd4,
	0x6b, 0xa3, 0xee, 0xed, 0x20, 0x49, 0xb8, 0x92, 0x52, 0xdd, 0x5b, 0x6c, 0xa1, 0xb6, 0xee, 0x44,
	0xdf, 0xfc, 0x8c, 0x65, 0xae, 0x61, 0xb7, 0x70, 0x18, 0xbd, 0x81, 0xae, 0xdb, 0x3b, 0xa1, 0xe6,
	0x6d, 0x29, 0xd1, 0x9b, 0x97, 0x44, 0xdb, 0x0c, 0xa9, 0x29, 0xf8, 0x31, 0x74, 0x5c, 0xf0, 0x5a,
	0xb3, 0x23, 0x40, 0x2b, 0xd2, 0x6e, 0xda, 0xa8, 0xf7, 0xb0, 0x59, 0xf5, 0xa0, 0xf3, 0x54, 0x48,
	0xca, 0x69, 0x82, 0x5e, 0xaf, 0xbe, 0x8c, 0x6b, 0x15, 0x55, 0x0c, 0xfc, 0xd5, 0x9a, 0xa1, 0x8e,
	0x2b, 0x2d, 0x6f, 0x53, 0xe3, 0xb2, 0xbe, 0xe6, 0x8a, 0xbe, 0x57, 0xcf, 0x01, 0x96, 0x0b, 0x8d,
	0x02, 0x68, 0x7f, 0x3a, 0x3d, 0x1c, 0x4f, 0xfb, 0x77, 0xd0, 0x06, 0x74, 0x8e, 0xc6, 0xc3, 0xe1,
	0xc1, 0xe8, 0xb8, 0xdf, 0x78, 0xb7, 0x6f, 0x9d, 0x40, 0x4f, 0xd7, 0xde, 0x99, 0x6b, 0x35, 0x2e,
	0xf4, 0x13, 0x13, 0xe1, 0xbf, 0x3f, 0xad, 0xa5, 0x59, 0x87, 0xf0, 0xa5, 0xfe, 0x63, 0x9d, 0xfb,
	0xe6, 0x93, 0xb7, 0xff, 0x03, 0x00, 0x00, 0xff, 0xff, 0xba, 0x94, 0xe9, 0xe7, 0xd4, 0x04, 0x00,
	0x00,
}
