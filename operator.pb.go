// Code generated by protoc-gen-go.
// source: operator.proto
// DO NOT EDIT!

/*
Package operator is a generated protocol buffer package.

It is generated from these files:
	operator.proto

It has these top-level messages:
	Request
	Response
	Call
	Source
	Room
	User
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
// A compilation error at this line likely means your copy of the
// proto package needs to be updated.
const _ = proto.ProtoPackageIsVersion2 // please upgrade the proto package

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
	Source   *Source `protobuf:"bytes,1,opt,name=source" json:"source,omitempty"`
	Call     *Call   `protobuf:"bytes,2,opt,name=call" json:"call,omitempty"`
	SenderId string  `protobuf:"bytes,3,opt,name=sender_id,json=senderId" json:"sender_id,omitempty"`
	Otp      string  `protobuf:"bytes,4,opt,name=otp" json:"otp,omitempty"`
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

func (m *Request) GetSenderId() string {
	if m != nil {
		return m.SenderId
	}
	return ""
}

func (m *Request) GetOtp() string {
	if m != nil {
		return m.Otp
	}
	return ""
}

type Response struct {
	Message string `protobuf:"bytes,1,opt,name=message" json:"message,omitempty"`
}

func (m *Response) Reset()                    { *m = Response{} }
func (m *Response) String() string            { return proto.CompactTextString(m) }
func (*Response) ProtoMessage()               {}
func (*Response) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{1} }

func (m *Response) GetMessage() string {
	if m != nil {
		return m.Message
	}
	return ""
}

// Call represents a completed gRPC call. The Error field will be non-nil if
// it resulted in an error.
type Call struct {
	Service  string                     `protobuf:"bytes,1,opt,name=service" json:"service,omitempty"`
	Method   string                     `protobuf:"bytes,2,opt,name=method" json:"method,omitempty"`
	Args     map[string]string          `protobuf:"bytes,3,rep,name=args" json:"args,omitempty" protobuf_key:"bytes,1,opt,name=key" protobuf_val:"bytes,2,opt,name=value"`
	Error    string                     `protobuf:"bytes,4,opt,name=error" json:"error,omitempty"`
	Duration *google_protobuf1.Duration `protobuf:"bytes,5,opt,name=duration" json:"duration,omitempty"`
}

func (m *Call) Reset()                    { *m = Call{} }
func (m *Call) String() string            { return proto.CompactTextString(m) }
func (*Call) ProtoMessage()               {}
func (*Call) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{2} }

func (m *Call) GetService() string {
	if m != nil {
		return m.Service
	}
	return ""
}

func (m *Call) GetMethod() string {
	if m != nil {
		return m.Method
	}
	return ""
}

func (m *Call) GetArgs() map[string]string {
	if m != nil {
		return m.Args
	}
	return nil
}

func (m *Call) GetError() string {
	if m != nil {
		return m.Error
	}
	return ""
}

func (m *Call) GetDuration() *google_protobuf1.Duration {
	if m != nil {
		return m.Duration
	}
	return nil
}

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

func (m *Source) GetType() SourceType {
	if m != nil {
		return m.Type
	}
	return SourceType_HUBOT
}

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

func (m *Source) GetHostname() string {
	if m != nil {
		return m.Hostname
	}
	return ""
}

type Room struct {
	Id   int64  `protobuf:"varint,1,opt,name=id" json:"id,omitempty"`
	Name string `protobuf:"bytes,2,opt,name=name" json:"name,omitempty"`
}

func (m *Room) Reset()                    { *m = Room{} }
func (m *Room) String() string            { return proto.CompactTextString(m) }
func (*Room) ProtoMessage()               {}
func (*Room) Descriptor() ([]byte, []int) { return fileDescriptor0, []int{4} }

func (m *Room) GetId() int64 {
	if m != nil {
		return m.Id
	}
	return 0
}

func (m *Room) GetName() string {
	if m != nil {
		return m.Name
	}
	return ""
}

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

func (m *User) GetId() string {
	if m != nil {
		return m.Id
	}
	return ""
}

func (m *User) GetLogin() string {
	if m != nil {
		return m.Login
	}
	return ""
}

func (m *User) GetRealName() string {
	if m != nil {
		return m.RealName
	}
	return ""
}

func (m *User) GetEmail() string {
	if m != nil {
		return m.Email
	}
	return ""
}

var E_Name = &proto.ExtensionDesc{
	ExtendedType:  (*google_protobuf.ServiceOptions)(nil),
	ExtensionType: (*string)(nil),
	Field:         51234,
	Name:          "operator.name",
	Tag:           "bytes,51234,opt,name=name",
	Filename:      "operator.proto",
}

func init() {
	proto.RegisterType((*Request)(nil), "operator.Request")
	proto.RegisterType((*Response)(nil), "operator.Response")
	proto.RegisterType((*Call)(nil), "operator.Call")
	proto.RegisterType((*Source)(nil), "operator.Source")
	proto.RegisterType((*Room)(nil), "operator.Room")
	proto.RegisterType((*User)(nil), "operator.User")
	proto.RegisterEnum("operator.SourceType", SourceType_name, SourceType_value)
	proto.RegisterExtension(E_Name)
}

func init() { proto.RegisterFile("operator.proto", fileDescriptor0) }

var fileDescriptor0 = []byte{
	// 515 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0x64, 0x93, 0x4d, 0x6b, 0xdb, 0x4e,
	0x10, 0xc6, 0xff, 0xb2, 0xe4, 0x17, 0x8d, 0xc1, 0x98, 0xc5, 0xfc, 0x51, 0x5d, 0x68, 0x8d, 0xc8,
	0xc1, 0x84, 0xa2, 0x80, 0x4b, 0x68, 0xc9, 0x2d, 0x2f, 0x85, 0xf6, 0x90, 0x18, 0x36, 0xc9, 0xa5,
	0x17, 0xb3, 0xb1, 0xa6, 0x8a, 0xa8, 0xa4, 0x55, 0x77, 0xa5, 0x80, 0xbf, 0x40, 0xcf, 0x3d, 0xf5,
	0x03, 0xf4, 0xf3, 0xf5, 0x43, 0x94, 0x9d, 0x95, 0xe4, 0xa6, 0xbe, 0xed, 0x33, 0xf3, 0xb3, 0xf6,
	0x99, 0x79, 0xd6, 0x30, 0x91, 0x25, 0x2a, 0x51, 0x49, 0x15, 0x95, 0x4a, 0x56, 0x92, 0x8d, 0x5a,
	0x3d, 0x5f, 0x24, 0x52, 0x26, 0x19, 0x9e, 0x50, 0xfd, 0xa1, 0xfe, 0x72, 0x12, 0xa3, 0xde, 0xaa,
	0xb4, 0xec, 0xd8, 0xf9, 0xab, 0x03, 0xa2, 0x56, 0xa2, 0x4a, 0x65, 0x61, 0xfb, 0xe1, 0x77, 0x07,
	0x86, 0x1c, 0xbf, 0xd5, 0xa8, 0x2b, 0xb6, 0x84, 0x81, 0x96, 0xb5, 0xda, 0x62, 0xe0, 0x2c, 0x9c,
	0xe5, 0x78, 0x35, 0x8d, 0xba, 0x8b, 0x6f, 0xa9, 0xce, 0x9b, 0x3e, 0x0b, 0xc1, 0xdb, 0x8a, 0x2c,
	0x0b, 0x7a, 0xc4, 0x4d, 0xf6, 0xdc, 0xa5, 0xc8, 0x32, 0x4e, 0x3d, 0xf6, 0x12, 0x7c, 0x8d, 0x45,
	0x8c, 0x6a, 0x93, 0xc6, 0x81, 0xbb, 0x70, 0x96, 0x3e, 0x1f, 0xd9, 0xc2, 0xa7, 0x98, 0x4d, 0xc1,
	0x95, 0x55, 0x19, 0x78, 0x54, 0x36, 0xc7, 0xf0, 0x08, 0x46, 0x1c, 0x75, 0x29, 0x0b, 0x8d, 0x2c,
	0x80, 0x61, 0x8e, 0x5a, 0x8b, 0xc4, 0x3a, 0xf1, 0x79, 0x2b, 0xc3, 0xdf, 0x0e, 0x78, 0xe6, 0x0e,
	0x83, 0x68, 0x54, 0x4f, 0xe9, 0xb6, 0x43, 0x1a, 0xc9, 0xfe, 0x87, 0x41, 0x8e, 0xd5, 0xa3, 0x8c,
	0xc9, 0x9d, 0xcf, 0x1b, 0xc5, 0xde, 0x80, 0x27, 0x54, 0xa2, 0x03, 0x77, 0xe1, 0x2e, 0xc7, 0xab,
	0xe0, 0xb9, 0xe7, 0xe8, 0x5c, 0x25, 0xfa, 0x43, 0x51, 0xa9, 0x1d, 0x27, 0x8a, 0xcd, 0xa0, 0x8f,
	0x4a, 0x49, 0xd5, 0x58, 0xb4, 0x82, 0x9d, 0xc2, 0xa8, 0xdd, 0x5f, 0xd0, 0xa7, 0xd9, 0x5f, 0x44,
	0x76, 0xc1, 0x51, 0xbb, 0xe0, 0xe8, 0xaa, 0x01, 0x78, 0x87, 0xce, 0xdf, 0x81, 0xdf, 0x7d, 0xdf,
	0x8c, 0xfe, 0x15, 0x77, 0x8d, 0x6b, 0x73, 0x34, 0x77, 0x3d, 0x89, 0xac, 0xc6, 0xc6, 0xb0, 0x15,
	0x67, 0xbd, 0xf7, 0x4e, 0xf8, 0xd3, 0x81, 0x81, 0x5d, 0x3d, 0x5b, 0x82, 0x57, 0xed, 0x4a, 0x3b,
	0xed, 0x64, 0x35, 0xfb, 0x37, 0x9a, 0xbb, 0x5d, 0x89, 0x9c, 0x08, 0x13, 0x4e, 0xad, 0x51, 0x1d,
	0x86, 0x73, 0xaf, 0x51, 0x71, 0xea, 0x19, 0x46, 0x49, 0x99, 0x53, 0x2e, 0xcf, 0x18, 0x2e, 0x65,
	0xce, 0xa9, 0xc7, 0xe6, 0x30, 0x7a, 0x94, 0xba, 0x2a, 0x44, 0x8e, 0xcd, 0x16, 0x3a, 0x1d, 0x1e,
	0x83, 0x67, 0x48, 0x36, 0x81, 0x5e, 0x1a, 0x93, 0x27, 0x97, 0xf7, 0xd2, 0x98, 0x31, 0xf0, 0x88,
	0xb7, 0x93, 0xd0, 0x39, 0xdc, 0x80, 0x67, 0x6e, 0xfe, 0x8b, 0xf5, 0x89, 0x9d, 0x41, 0x3f, 0x93,
	0x49, 0x5a, 0xb4, 0x63, 0x93, 0x30, 0xcf, 0x46, 0xa1, 0xc8, 0x36, 0xf4, 0x99, 0xe6, 0xd9, 0x98,
	0xc2, 0x8d, 0xc8, 0x91, 0x52, 0xc9, 0x45, 0x9a, 0x75, 0xa9, 0x18, 0x71, 0x7c, 0x04, 0xb0, 0x5f,
	0x02, 0xf3, 0xa1, 0xff, 0xf1, 0xfe, 0x62, 0x7d, 0x37, 0xfd, 0x8f, 0x8d, 0x61, 0x78, 0xb9, 0xbe,
	0xbe, 0x3e, 0xbf, 0xb9, 0x9a, 0x3a, 0x67, 0xa7, 0xd6, 0x1a, 0x7b, 0x7d, 0x90, 0xd8, 0xad, 0x7d,
	0x39, 0xeb, 0xd2, 0x84, 0xa5, 0x83, 0x5f, 0x3f, 0xdc, 0xbd, 0xfb, 0x0b, 0xf8, 0xdc, 0xfd, 0xdd,
	0x1e, 0x06, 0xf4, 0x93, 0xb7, 0x7f, 0x02, 0x00, 0x00, 0xff, 0xff, 0x6e, 0x9d, 0x59, 0xb2, 0x91,
	0x03, 0x00, 0x00,
}
