// Code generated by protoc-gen-go.
// source: google/iam/v1/policy.proto
// DO NOT EDIT!

package google_iam_v1

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// # Overview
//
// The `Policy` defines an access control policy language. It is used to
// define policies that are attached to resources like files, folders, VMs,
// etc.
//
//
// # Policy structure
//
// A `Policy` consists of a list of bindings. A `Binding` binds a set of members
// to a role, where the members include user accounts, user groups, user
// domains, and service accounts. A 'role' is a named set of permissions,
// defined by IAM. The definition of a role is outside the policy.
//
// A permission check first determines the roles that include the specified
// permission, and then determines if the principal specified is a
// member of a binding to at least one of these roles. The membership check is
// recursive when a group is bound to a role.
//
// Policy examples:
//
// ```
// {
//   "bindings": [
//     {
//       "role": "roles/owner",
//       "members": [
//         "user:mike@example.com",
//         "group:admins@example.com",
//         "domain:google.com",
//         "serviceAccount:frontend@example.iam.gserviceaccounts.com"]
//     },
//     {
//       "role": "roles/viewer",
//       "members": ["user:sean@example.com"]
//     }
//   ]
// }
// ```
type Policy struct {
	// The policy language version. The version of the policy is
	// represented by the etag. The default version is 0.
	Version int32 `protobuf:"varint,1,opt,name=version" json:"version,omitempty"`
	// It is an error to specify multiple bindings for the same role.
	// It is an error to specify a binding with no members.
	Bindings []*Binding `protobuf:"bytes,4,rep,name=bindings" json:"bindings,omitempty"`
	// Can be used to perform a read-modify-write.
	Etag []byte `protobuf:"bytes,3,opt,name=etag,proto3" json:"etag,omitempty"`
}

func (m *Policy) Reset()                    { *m = Policy{} }
func (m *Policy) String() string            { return proto.CompactTextString(m) }
func (*Policy) ProtoMessage()               {}
func (*Policy) Descriptor() ([]byte, []int) { return fileDescriptor1, []int{0} }

func (m *Policy) GetBindings() []*Binding {
	if m != nil {
		return m.Bindings
	}
	return nil
}

// Associates members with roles. See below for allowed
// formats of members.
type Binding struct {
	// The name of the role to which the members should be bound.
	// Examples: "roles/viewer", "roles/editor", "roles/owner".
	// Required
	Role string `protobuf:"bytes,1,opt,name=role" json:"role,omitempty"`
	// Format of member entries:
	// 1. allUsers
	//    Matches any requesting principal (users, service accounts or anonymous).
	//
	// 2. allAuthenticatedUsers
	//    Matches any requesting authenticated principal (users or service
	//    accounts).
	//
	// 3. user:{emailid}
	//    A google user account using an email address.
	//    For example alice@gmail.com, joe@example.com
	//
	// 4. serviceAccount:{emailid}
	//    An service account email.
	//
	// 5. group:{emailid}
	//    A google group with an email address. For example
	//    auth-ti-cloud@google.com
	//
	// 6. domain:{domain}
	//    A Google Apps domain name.
	//    For example google.com, example.com
	Members []string `protobuf:"bytes,2,rep,name=members" json:"members,omitempty"`
}

func (m *Binding) Reset()                    { *m = Binding{} }
func (m *Binding) String() string            { return proto.CompactTextString(m) }
func (*Binding) ProtoMessage()               {}
func (*Binding) Descriptor() ([]byte, []int) { return fileDescriptor1, []int{1} }

func init() {
	proto.RegisterType((*Policy)(nil), "google.iam.v1.Policy")
	proto.RegisterType((*Binding)(nil), "google.iam.v1.Binding")
}

var fileDescriptor1 = []byte{
	// 175 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0x54, 0x8e, 0x41, 0xaa, 0x83, 0x30,
	0x14, 0x45, 0xf1, 0xeb, 0xd7, 0xfa, 0xb4, 0x94, 0x66, 0x50, 0x42, 0x47, 0xe2, 0x28, 0xa3, 0x88,
	0xed, 0x0e, 0x5c, 0x81, 0x5d, 0x82, 0xda, 0x10, 0x02, 0xc6, 0x27, 0x2a, 0x81, 0xee, 0xbe, 0x31,
	0x99, 0xd4, 0xf1, 0xe1, 0x9e, 0x7b, 0xe0, 0x2e, 0x11, 0xe5, 0x28, 0x2a, 0xd5, 0xe9, 0xca, 0xd4,
	0xd5, 0x8c, 0xa3, 0x1a, 0x3e, 0x7c, 0x5e, 0x70, 0x43, 0x72, 0xf6, 0x8c, 0x5b, 0xc6, 0x4d, 0x5d,
	0xbe, 0x20, 0x6e, 0x1d, 0x26, 0x17, 0x48, 0x8c, 0x58, 0x56, 0x85, 0x13, 0x0d, 0x8a, 0x80, 0xfd,
	0x13, 0x06, 0xa7, 0x5e, 0x4d, 0x6f, 0x35, 0xc9, 0x95, 0x46, 0x45, 0xc8, 0xb2, 0xc7, 0x8d, 0x1f,
	0xc6, 0xbc, 0xf1, 0x98, 0xe4, 0x10, 0x89, 0xad, 0x93, 0x34, 0xb4, 0xbb, 0xbc, 0x64, 0x90, 0xfc,
	0x80, 0x05, 0x47, 0xe1, 0x84, 0xe9, 0xfe, 0xa0, 0x85, 0xee, 0xed, 0x09, 0xfd, 0xb3, 0xbe, 0xb4,
	0x29, 0xe1, 0x3a, 0xa0, 0x3e, 0x4a, 0x9b, 0xcc, 0xf7, 0xb4, 0x7b, 0x6d, 0x1b, 0xf4, 0xb1, 0xcb,
	0x7e, 0x7e, 0x03, 0x00, 0x00, 0xff, 0xff, 0x8f, 0x97, 0x05, 0x1c, 0xd4, 0x00, 0x00, 0x00,
}
