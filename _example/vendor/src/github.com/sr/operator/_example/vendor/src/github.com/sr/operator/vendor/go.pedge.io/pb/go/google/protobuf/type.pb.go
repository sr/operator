// Code generated by protoc-gen-go.
// source: google/protobuf/type.proto
// DO NOT EDIT!

package google_protobuf

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// The syntax in which a protocol buffer element is defined.
type Syntax int32

const (
	// Syntax `proto2`.
	Syntax_SYNTAX_PROTO2 Syntax = 0
	// Syntax `proto3`.
	Syntax_SYNTAX_PROTO3 Syntax = 1
)

var Syntax_name = map[int32]string{
	0: "SYNTAX_PROTO2",
	1: "SYNTAX_PROTO3",
}
var Syntax_value = map[string]int32{
	"SYNTAX_PROTO2": 0,
	"SYNTAX_PROTO3": 1,
}

func (x Syntax) String() string {
	return proto.EnumName(Syntax_name, int32(x))
}
func (Syntax) EnumDescriptor() ([]byte, []int) { return fileDescriptor8, []int{0} }

// Basic field types.
type Field_Kind int32

const (
	// Field type unknown.
	Field_TYPE_UNKNOWN Field_Kind = 0
	// Field type double.
	Field_TYPE_DOUBLE Field_Kind = 1
	// Field type float.
	Field_TYPE_FLOAT Field_Kind = 2
	// Field type int64.
	Field_TYPE_INT64 Field_Kind = 3
	// Field type uint64.
	Field_TYPE_UINT64 Field_Kind = 4
	// Field type int32.
	Field_TYPE_INT32 Field_Kind = 5
	// Field type fixed64.
	Field_TYPE_FIXED64 Field_Kind = 6
	// Field type fixed32.
	Field_TYPE_FIXED32 Field_Kind = 7
	// Field type bool.
	Field_TYPE_BOOL Field_Kind = 8
	// Field type string.
	Field_TYPE_STRING Field_Kind = 9
	// Field type group. Proto2 syntax only, and deprecated.
	Field_TYPE_GROUP Field_Kind = 10
	// Field type message.
	Field_TYPE_MESSAGE Field_Kind = 11
	// Field type bytes.
	Field_TYPE_BYTES Field_Kind = 12
	// Field type uint32.
	Field_TYPE_UINT32 Field_Kind = 13
	// Field type enum.
	Field_TYPE_ENUM Field_Kind = 14
	// Field type sfixed32.
	Field_TYPE_SFIXED32 Field_Kind = 15
	// Field type sfixed64.
	Field_TYPE_SFIXED64 Field_Kind = 16
	// Field type sint32.
	Field_TYPE_SINT32 Field_Kind = 17
	// Field type sint64.
	Field_TYPE_SINT64 Field_Kind = 18
)

var Field_Kind_name = map[int32]string{
	0:  "TYPE_UNKNOWN",
	1:  "TYPE_DOUBLE",
	2:  "TYPE_FLOAT",
	3:  "TYPE_INT64",
	4:  "TYPE_UINT64",
	5:  "TYPE_INT32",
	6:  "TYPE_FIXED64",
	7:  "TYPE_FIXED32",
	8:  "TYPE_BOOL",
	9:  "TYPE_STRING",
	10: "TYPE_GROUP",
	11: "TYPE_MESSAGE",
	12: "TYPE_BYTES",
	13: "TYPE_UINT32",
	14: "TYPE_ENUM",
	15: "TYPE_SFIXED32",
	16: "TYPE_SFIXED64",
	17: "TYPE_SINT32",
	18: "TYPE_SINT64",
}
var Field_Kind_value = map[string]int32{
	"TYPE_UNKNOWN":  0,
	"TYPE_DOUBLE":   1,
	"TYPE_FLOAT":    2,
	"TYPE_INT64":    3,
	"TYPE_UINT64":   4,
	"TYPE_INT32":    5,
	"TYPE_FIXED64":  6,
	"TYPE_FIXED32":  7,
	"TYPE_BOOL":     8,
	"TYPE_STRING":   9,
	"TYPE_GROUP":    10,
	"TYPE_MESSAGE":  11,
	"TYPE_BYTES":    12,
	"TYPE_UINT32":   13,
	"TYPE_ENUM":     14,
	"TYPE_SFIXED32": 15,
	"TYPE_SFIXED64": 16,
	"TYPE_SINT32":   17,
	"TYPE_SINT64":   18,
}

func (x Field_Kind) String() string {
	return proto.EnumName(Field_Kind_name, int32(x))
}
func (Field_Kind) EnumDescriptor() ([]byte, []int) { return fileDescriptor8, []int{1, 0} }

// Whether a field is optional, required, or repeated.
type Field_Cardinality int32

const (
	// For fields with unknown cardinality.
	Field_CARDINALITY_UNKNOWN Field_Cardinality = 0
	// For optional fields.
	Field_CARDINALITY_OPTIONAL Field_Cardinality = 1
	// For required fields. Proto2 syntax only.
	Field_CARDINALITY_REQUIRED Field_Cardinality = 2
	// For repeated fields.
	Field_CARDINALITY_REPEATED Field_Cardinality = 3
)

var Field_Cardinality_name = map[int32]string{
	0: "CARDINALITY_UNKNOWN",
	1: "CARDINALITY_OPTIONAL",
	2: "CARDINALITY_REQUIRED",
	3: "CARDINALITY_REPEATED",
}
var Field_Cardinality_value = map[string]int32{
	"CARDINALITY_UNKNOWN":  0,
	"CARDINALITY_OPTIONAL": 1,
	"CARDINALITY_REQUIRED": 2,
	"CARDINALITY_REPEATED": 3,
}

func (x Field_Cardinality) String() string {
	return proto.EnumName(Field_Cardinality_name, int32(x))
}
func (Field_Cardinality) EnumDescriptor() ([]byte, []int) { return fileDescriptor8, []int{1, 1} }

// A protocol buffer message type.
type Type struct {
	// The fully qualified message name.
	Name string `protobuf:"bytes,1,opt,name=name" json:"name,omitempty"`
	// The list of fields.
	Fields []*Field `protobuf:"bytes,2,rep,name=fields" json:"fields,omitempty"`
	// The list of types appearing in `oneof` definitions in this type.
	Oneofs []string `protobuf:"bytes,3,rep,name=oneofs" json:"oneofs,omitempty"`
	// The protocol buffer options.
	Options []*Option `protobuf:"bytes,4,rep,name=options" json:"options,omitempty"`
	// The source context.
	SourceContext *SourceContext `protobuf:"bytes,5,opt,name=source_context" json:"source_context,omitempty"`
	// The source syntax.
	Syntax Syntax `protobuf:"varint,6,opt,name=syntax,enum=google.protobuf.Syntax" json:"syntax,omitempty"`
}

func (m *Type) Reset()                    { *m = Type{} }
func (m *Type) String() string            { return proto.CompactTextString(m) }
func (*Type) ProtoMessage()               {}
func (*Type) Descriptor() ([]byte, []int) { return fileDescriptor8, []int{0} }

func (m *Type) GetFields() []*Field {
	if m != nil {
		return m.Fields
	}
	return nil
}

func (m *Type) GetOptions() []*Option {
	if m != nil {
		return m.Options
	}
	return nil
}

func (m *Type) GetSourceContext() *SourceContext {
	if m != nil {
		return m.SourceContext
	}
	return nil
}

// A single field of a message type.
type Field struct {
	// The field type.
	Kind Field_Kind `protobuf:"varint,1,opt,name=kind,enum=google.protobuf.Field_Kind" json:"kind,omitempty"`
	// The field cardinality.
	Cardinality Field_Cardinality `protobuf:"varint,2,opt,name=cardinality,enum=google.protobuf.Field_Cardinality" json:"cardinality,omitempty"`
	// The field number.
	Number int32 `protobuf:"varint,3,opt,name=number" json:"number,omitempty"`
	// The field name.
	Name string `protobuf:"bytes,4,opt,name=name" json:"name,omitempty"`
	// The field type URL, without the scheme, for message or enumeration
	// types. Example: `"type.googleapis.com/google.protobuf.Timestamp"`.
	TypeUrl string `protobuf:"bytes,6,opt,name=type_url" json:"type_url,omitempty"`
	// The index of the field type in `Type.oneofs`, for message or enumeration
	// types. The first type has index 1; zero means the type is not in the list.
	OneofIndex int32 `protobuf:"varint,7,opt,name=oneof_index" json:"oneof_index,omitempty"`
	// Whether to use alternative packed wire representation.
	Packed bool `protobuf:"varint,8,opt,name=packed" json:"packed,omitempty"`
	// The protocol buffer options.
	Options []*Option `protobuf:"bytes,9,rep,name=options" json:"options,omitempty"`
	// The field JSON name.
	JsonName string `protobuf:"bytes,10,opt,name=json_name" json:"json_name,omitempty"`
	// The string value of the default value of this field. Proto2 syntax only.
	DefaultValue string `protobuf:"bytes,11,opt,name=default_value" json:"default_value,omitempty"`
}

func (m *Field) Reset()                    { *m = Field{} }
func (m *Field) String() string            { return proto.CompactTextString(m) }
func (*Field) ProtoMessage()               {}
func (*Field) Descriptor() ([]byte, []int) { return fileDescriptor8, []int{1} }

func (m *Field) GetOptions() []*Option {
	if m != nil {
		return m.Options
	}
	return nil
}

// Enum type definition.
type Enum struct {
	// Enum type name.
	Name string `protobuf:"bytes,1,opt,name=name" json:"name,omitempty"`
	// Enum value definitions.
	Enumvalue []*EnumValue `protobuf:"bytes,2,rep,name=enumvalue" json:"enumvalue,omitempty"`
	// Protocol buffer options.
	Options []*Option `protobuf:"bytes,3,rep,name=options" json:"options,omitempty"`
	// The source context.
	SourceContext *SourceContext `protobuf:"bytes,4,opt,name=source_context" json:"source_context,omitempty"`
	// The source syntax.
	Syntax Syntax `protobuf:"varint,5,opt,name=syntax,enum=google.protobuf.Syntax" json:"syntax,omitempty"`
}

func (m *Enum) Reset()                    { *m = Enum{} }
func (m *Enum) String() string            { return proto.CompactTextString(m) }
func (*Enum) ProtoMessage()               {}
func (*Enum) Descriptor() ([]byte, []int) { return fileDescriptor8, []int{2} }

func (m *Enum) GetEnumvalue() []*EnumValue {
	if m != nil {
		return m.Enumvalue
	}
	return nil
}

func (m *Enum) GetOptions() []*Option {
	if m != nil {
		return m.Options
	}
	return nil
}

func (m *Enum) GetSourceContext() *SourceContext {
	if m != nil {
		return m.SourceContext
	}
	return nil
}

// Enum value definition.
type EnumValue struct {
	// Enum value name.
	Name string `protobuf:"bytes,1,opt,name=name" json:"name,omitempty"`
	// Enum value number.
	Number int32 `protobuf:"varint,2,opt,name=number" json:"number,omitempty"`
	// Protocol buffer options.
	Options []*Option `protobuf:"bytes,3,rep,name=options" json:"options,omitempty"`
}

func (m *EnumValue) Reset()                    { *m = EnumValue{} }
func (m *EnumValue) String() string            { return proto.CompactTextString(m) }
func (*EnumValue) ProtoMessage()               {}
func (*EnumValue) Descriptor() ([]byte, []int) { return fileDescriptor8, []int{3} }

func (m *EnumValue) GetOptions() []*Option {
	if m != nil {
		return m.Options
	}
	return nil
}

// A protocol buffer option, which can be attached to a message, field,
// enumeration, etc.
type Option struct {
	// The option's name. For example, `"java_package"`.
	Name string `protobuf:"bytes,1,opt,name=name" json:"name,omitempty"`
	// The option's value. For example, `"com.google.protobuf"`.
	Value *Any `protobuf:"bytes,2,opt,name=value" json:"value,omitempty"`
}

func (m *Option) Reset()                    { *m = Option{} }
func (m *Option) String() string            { return proto.CompactTextString(m) }
func (*Option) ProtoMessage()               {}
func (*Option) Descriptor() ([]byte, []int) { return fileDescriptor8, []int{4} }

func (m *Option) GetValue() *Any {
	if m != nil {
		return m.Value
	}
	return nil
}

func init() {
	proto.RegisterType((*Type)(nil), "google.protobuf.Type")
	proto.RegisterType((*Field)(nil), "google.protobuf.Field")
	proto.RegisterType((*Enum)(nil), "google.protobuf.Enum")
	proto.RegisterType((*EnumValue)(nil), "google.protobuf.EnumValue")
	proto.RegisterType((*Option)(nil), "google.protobuf.Option")
	proto.RegisterEnum("google.protobuf.Syntax", Syntax_name, Syntax_value)
	proto.RegisterEnum("google.protobuf.Field_Kind", Field_Kind_name, Field_Kind_value)
	proto.RegisterEnum("google.protobuf.Field_Cardinality", Field_Cardinality_name, Field_Cardinality_value)
}

var fileDescriptor8 = []byte{
	// 712 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0x94, 0x54, 0xc1, 0x6e, 0xda, 0x4a,
	0x14, 0x7d, 0x06, 0xe3, 0xe0, 0xeb, 0x40, 0x26, 0x4e, 0xde, 0x8b, 0x1f, 0x4f, 0x8a, 0x22, 0xbf,
	0xaa, 0xa5, 0x95, 0x4a, 0x24, 0x52, 0xa5, 0x8b, 0xae, 0x4c, 0x70, 0x90, 0x15, 0x62, 0xbb, 0xd8,
	0x34, 0x61, 0x65, 0x39, 0x30, 0x44, 0x34, 0x8e, 0x8d, 0xb0, 0x69, 0xc3, 0xdf, 0x54, 0x5d, 0xf6,
	0x4b, 0xba, 0xea, 0xae, 0xea, 0xef, 0x74, 0x3c, 0x2e, 0x06, 0x4c, 0x1a, 0x35, 0x3b, 0xe6, 0x9e,
	0x73, 0xef, 0x39, 0x73, 0x3c, 0x17, 0xa8, 0x5c, 0x07, 0xc1, 0xb5, 0x87, 0x0f, 0xc7, 0x93, 0x20,
	0x0a, 0xae, 0xa6, 0xc3, 0xc3, 0x68, 0x36, 0xc6, 0x35, 0x7a, 0x12, 0xb7, 0x12, 0xac, 0x36, 0xc7,
	0x2a, 0xff, 0x66, 0xc9, 0xae, 0x3f, 0x4b, 0xd0, 0xca, 0x93, 0x2c, 0x14, 0x06, 0xd3, 0x49, 0x1f,
	0x3b, 0xfd, 0xc0, 0x8f, 0xf0, 0x5d, 0x94, 0xb0, 0xe4, 0x1f, 0x0c, 0xb0, 0x36, 0x11, 0x10, 0x37,
	0x81, 0xf5, 0xdd, 0x5b, 0x2c, 0x31, 0x07, 0x4c, 0x95, 0x17, 0x9f, 0x02, 0x37, 0x1c, 0x61, 0x6f,
	0x10, 0x4a, 0xb9, 0x83, 0x7c, 0x55, 0xa8, 0xff, 0x53, 0xcb, 0x28, 0xd7, 0x4e, 0x63, 0x58, 0x2c,
	0x03, 0x17, 0xf8, 0x38, 0x18, 0x86, 0x52, 0x9e, 0xf0, 0x78, 0xb1, 0x0a, 0x1b, 0xc1, 0x38, 0x1a,
	0x05, 0x7e, 0x28, 0xb1, 0xb4, 0x71, 0x6f, 0xad, 0xd1, 0xa0, 0xb8, 0x78, 0x0c, 0xe5, 0x55, 0x43,
	0x52, 0x81, 0x28, 0x0b, 0xf5, 0xfd, 0xb5, 0x06, 0x8b, 0xd2, 0x4e, 0x12, 0x96, 0xf8, 0x0c, 0xb8,
	0x70, 0xe6, 0x47, 0xee, 0x9d, 0xc4, 0x11, 0x7e, 0xf9, 0x1e, 0x01, 0x8b, 0xc2, 0xf2, 0xf7, 0x02,
	0x14, 0x12, 0x93, 0xcf, 0x81, 0xbd, 0x19, 0xf9, 0x03, 0x7a, 0xb5, 0x72, 0xfd, 0xbf, 0xfb, 0xaf,
	0x52, 0x3b, 0x23, 0x14, 0xf1, 0x35, 0x08, 0x7d, 0x77, 0x32, 0x18, 0xf9, 0xae, 0x37, 0x8a, 0x66,
	0xe4, 0xf2, 0x71, 0x87, 0xfc, 0x9b, 0x8e, 0x93, 0x05, 0x33, 0x0e, 0xc2, 0x9f, 0xde, 0x5e, 0xe1,
	0x09, 0x09, 0x82, 0xa9, 0x16, 0xd2, 0x38, 0x59, 0x1a, 0x27, 0x82, 0x62, 0xfc, 0x15, 0x9d, 0xe9,
	0xc4, 0xa3, 0xb6, 0x79, 0x71, 0x07, 0x04, 0x1a, 0x9c, 0x43, 0x54, 0xf1, 0x9d, 0xb4, 0x41, 0x9b,
	0xc8, 0x90, 0xb1, 0xdb, 0xbf, 0xc1, 0x03, 0xa9, 0x48, 0xce, 0xc5, 0xe5, 0x34, 0xf9, 0x87, 0xd3,
	0xdc, 0x06, 0xfe, 0x7d, 0x18, 0xf8, 0x0e, 0xd5, 0x04, 0xaa, 0xf0, 0x37, 0x94, 0x06, 0x78, 0xe8,
	0x4e, 0xbd, 0xc8, 0xf9, 0xe0, 0x7a, 0x53, 0x2c, 0x09, 0x71, 0x59, 0xfe, 0x9a, 0x03, 0x96, 0x5e,
	0x15, 0xc1, 0xa6, 0xdd, 0x33, 0x55, 0xa7, 0xab, 0x9f, 0xe9, 0xc6, 0x85, 0x8e, 0xfe, 0x12, 0xb7,
	0x40, 0xa0, 0x95, 0xa6, 0xd1, 0x6d, 0xb4, 0x55, 0xc4, 0x10, 0x3f, 0x40, 0x0b, 0xa7, 0x6d, 0x43,
	0xb1, 0x51, 0x2e, 0x3d, 0x6b, 0xba, 0x7d, 0xfc, 0x0a, 0xe5, 0xd3, 0x86, 0x6e, 0x52, 0x60, 0x97,
	0x09, 0x47, 0x75, 0x54, 0x48, 0x35, 0x4e, 0xb5, 0x4b, 0xb5, 0x49, 0x18, 0xdc, 0x6a, 0x85, 0x70,
	0x36, 0xc4, 0x12, 0xf0, 0xb4, 0xd2, 0x30, 0x8c, 0x36, 0x2a, 0xa6, 0x33, 0x2d, 0xbb, 0xa3, 0xe9,
	0x2d, 0xc4, 0xa7, 0x33, 0x5b, 0x1d, 0xa3, 0x6b, 0x22, 0x48, 0x27, 0x9c, 0xab, 0x96, 0xa5, 0xb4,
	0x54, 0x24, 0xa4, 0x8c, 0x46, 0xcf, 0x56, 0x2d, 0xb4, 0xb9, 0x62, 0x8b, 0x48, 0x94, 0x52, 0x09,
	0x55, 0xef, 0x9e, 0xa3, 0x32, 0x09, 0xab, 0x94, 0x48, 0xcc, 0x4d, 0x6c, 0x65, 0x4a, 0xc4, 0x29,
	0x5a, 0x18, 0x49, 0xa6, 0x6c, 0xaf, 0x14, 0x08, 0x43, 0x94, 0x23, 0x10, 0x96, 0x9f, 0xc0, 0x1e,
	0xec, 0x9c, 0x28, 0x9d, 0xa6, 0xa6, 0x2b, 0x6d, 0xcd, 0xee, 0x2d, 0xe5, 0x2a, 0xc1, 0xee, 0x32,
	0x60, 0x98, 0xb6, 0x66, 0x90, 0xdf, 0x24, 0xe0, 0x0c, 0xd2, 0x51, 0xdf, 0x76, 0xb5, 0x8e, 0xda,
	0x24, 0x51, 0xaf, 0x21, 0xa6, 0xaa, 0xd8, 0x04, 0xc9, 0xcb, 0xdf, 0xc8, 0xc6, 0xaa, 0xe4, 0xad,
	0x65, 0x36, 0xf6, 0x25, 0xf0, 0x98, 0x54, 0x93, 0x4f, 0x9d, 0x2c, 0x6d, 0x65, 0xed, 0xb5, 0xc4,
	0x7d, 0xef, 0x62, 0xc6, 0xf2, 0xd3, 0xca, 0x3f, 0x76, 0x51, 0xd9, 0x47, 0x2e, 0x6a, 0xe1, 0xe1,
	0x45, 0xb5, 0x80, 0x5f, 0xf8, 0x5a, 0xbd, 0xd4, 0x62, 0xab, 0x72, 0x74, 0x41, 0xfe, 0xd8, 0xb5,
	0xfc, 0x06, 0xb8, 0x5f, 0xfe, 0x57, 0x27, 0xfe, 0x0f, 0x85, 0x79, 0x44, 0xf1, 0x25, 0x76, 0xd7,
	0xfa, 0x15, 0x7f, 0xf6, 0xa2, 0x06, 0x5c, 0xe2, 0x2d, 0x7e, 0x17, 0x56, 0x4f, 0xb7, 0x95, 0x4b,
	0xc7, 0xec, 0x18, 0xb6, 0x51, 0x27, 0x5f, 0x33, 0x53, 0x3a, 0x42, 0x4c, 0xa3, 0x0d, 0x3b, 0xfd,
	0xe0, 0x36, 0x3b, 0xaa, 0xc1, 0xc7, 0x7f, 0xac, 0x66, 0x7c, 0x32, 0x99, 0x4f, 0x0c, 0xf3, 0x39,
	0x97, 0x6f, 0x99, 0x8d, 0x2f, 0xb9, 0xfd, 0x56, 0xc2, 0x33, 0xe7, 0x92, 0x17, 0xd8, 0xf3, 0xce,
	0xfc, 0xe0, 0xa3, 0x1f, 0xf3, 0xc3, 0x2b, 0x8e, 0x0e, 0x38, 0xfa, 0x19, 0x00, 0x00, 0xff, 0xff,
	0x18, 0x41, 0x99, 0xa0, 0x09, 0x06, 0x00, 0x00,
}
