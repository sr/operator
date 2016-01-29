// Code generated by protoc-gen-gogo.
// source: google/logging/v2/logging_config.proto
// DO NOT EDIT!

package google_logging_v2

import proto "github.com/gogo/protobuf/proto"
import fmt "fmt"
import math "math"
import _ "github.com/peter-edge/grpc-gateway-gogo/third_party/googleapis/google/api"
import _ "go.pedge.io/pb/gogo/google/protobuf"
import _ "go.pedge.io/pb/gogo/google/protobuf"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// Available log entry formats. Log entries can be written to Cloud
// Logging in either format and can be exported in either format.
// Version 2 is the preferred format.
type LogSink_VersionFormat int32

const (
	// An unspecified version format will default to V2.
	LogSink_VERSION_FORMAT_UNSPECIFIED LogSink_VersionFormat = 0
	// `LogEntry` version 2 format.
	LogSink_V2 LogSink_VersionFormat = 1
	// `LogEntry` version 1 format.
	LogSink_V1 LogSink_VersionFormat = 2
)

var LogSink_VersionFormat_name = map[int32]string{
	0: "VERSION_FORMAT_UNSPECIFIED",
	1: "V2",
	2: "V1",
}
var LogSink_VersionFormat_value = map[string]int32{
	"VERSION_FORMAT_UNSPECIFIED": 0,
	"V2": 1,
	"V1": 2,
}

func (x LogSink_VersionFormat) String() string {
	return proto.EnumName(LogSink_VersionFormat_name, int32(x))
}

// Describes a sink used to export log entries outside Cloud Logging.
type LogSink struct {
	// Required. The client-assigned sink identifier. Example:
	// `"my-severe-errors-to-pubsub"`.
	// Sink identifiers are limited to 1000 characters
	// and can include only the following characters: `A-Z`, `a-z`,
	// `0-9`, and the special characters `_-.`.
	Name string `protobuf:"bytes,1,opt,name=name,proto3" json:"name,omitempty"`
	// The export destination. See
	// [Exporting Logs With Sinks](/logging/docs/api/tasks/exporting-logs).
	// Examples: `"storage.googleapis.com/a-bucket"`,
	// `"bigquery.googleapis.com/projects/a-project-id/datasets/a-dataset"`.
	Destination string `protobuf:"bytes,3,opt,name=destination,proto3" json:"destination,omitempty"`
	// An [advanced logs filter](/logging/docs/view/advanced_filters)
	// that defines the log entries to be exported.  The filter must be
	// consistent with the log entry format designed by the
	// `outputVersionFormat` parameter, regardless of the format of the
	// log entry that was originally written to Cloud Logging.
	// Example: `"logName:syslog AND severity>=ERROR"`.
	Filter string `protobuf:"bytes,5,opt,name=filter,proto3" json:"filter,omitempty"`
	// The log entry version used when exporting log entries from this
	// sink.  This version does not have to correspond to the version of
	// the log entry when it was written to Cloud Logging.
	OutputVersionFormat LogSink_VersionFormat `protobuf:"varint,6,opt,name=output_version_format,proto3,enum=google.logging.v2.LogSink_VersionFormat" json:"output_version_format,omitempty"`
}

func (m *LogSink) Reset()         { *m = LogSink{} }
func (m *LogSink) String() string { return proto.CompactTextString(m) }
func (*LogSink) ProtoMessage()    {}

// The parameters to `ListSinks`.
type ListSinksRequest struct {
	// Required. The resource name of the project containing the sinks.
	// Example: `"projects/my-logging-project"`, `"projects/01234567890"`.
	ProjectName string `protobuf:"bytes,1,opt,name=project_name,proto3" json:"project_name,omitempty"`
	// Optional. If the `pageToken` request parameter is supplied, then the next
	// page of results in the set are retrieved.  The `pageToken` parameter must
	// be set with the value of the `nextPageToken` result parameter from the
	// previous request. The value of `projectName` must be the same as in the
	// previous request.
	PageToken string `protobuf:"bytes,2,opt,name=page_token,proto3" json:"page_token,omitempty"`
	// Optional. The maximum number of results to return from this request.  Fewer
	// results might be returned. You must check for the `nextPageToken` result to
	// determine if additional results are available, which you can retrieve by
	// passing the `nextPageToken` value in the `pageToken` parameter to the next
	// request.
	PageSize int32 `protobuf:"varint,3,opt,name=page_size,proto3" json:"page_size,omitempty"`
}

func (m *ListSinksRequest) Reset()         { *m = ListSinksRequest{} }
func (m *ListSinksRequest) String() string { return proto.CompactTextString(m) }
func (*ListSinksRequest) ProtoMessage()    {}

// Result returned from `ListSinks`.
type ListSinksResponse struct {
	// A list of sinks.
	Sinks []*LogSink `protobuf:"bytes,1,rep,name=sinks" json:"sinks,omitempty"`
	// If there are more results than were returned, then `nextPageToken` is
	// given a value in the response.  To get the next batch of results, call this
	// method again using the value of `nextPageToken` as `pageToken`.
	NextPageToken string `protobuf:"bytes,2,opt,name=next_page_token,proto3" json:"next_page_token,omitempty"`
}

func (m *ListSinksResponse) Reset()         { *m = ListSinksResponse{} }
func (m *ListSinksResponse) String() string { return proto.CompactTextString(m) }
func (*ListSinksResponse) ProtoMessage()    {}

func (m *ListSinksResponse) GetSinks() []*LogSink {
	if m != nil {
		return m.Sinks
	}
	return nil
}

// The parameters to `GetSink`.
type GetSinkRequest struct {
	// The resource name of the sink to return.
	// Example: `"projects/my-project-id/sinks/my-sink-id"`.
	SinkName string `protobuf:"bytes,1,opt,name=sink_name,proto3" json:"sink_name,omitempty"`
}

func (m *GetSinkRequest) Reset()         { *m = GetSinkRequest{} }
func (m *GetSinkRequest) String() string { return proto.CompactTextString(m) }
func (*GetSinkRequest) ProtoMessage()    {}

// The parameters to `CreateSink`.
type CreateSinkRequest struct {
	// The resource name of the project in which to create the sink.
	// Example: `"projects/my-project-id"`.
	//
	// The new sink must be provided in the request.
	ProjectName string `protobuf:"bytes,1,opt,name=project_name,proto3" json:"project_name,omitempty"`
	// The new sink, which must not have an identifier that already
	// exists.
	Sink *LogSink `protobuf:"bytes,2,opt,name=sink" json:"sink,omitempty"`
}

func (m *CreateSinkRequest) Reset()         { *m = CreateSinkRequest{} }
func (m *CreateSinkRequest) String() string { return proto.CompactTextString(m) }
func (*CreateSinkRequest) ProtoMessage()    {}

func (m *CreateSinkRequest) GetSink() *LogSink {
	if m != nil {
		return m.Sink
	}
	return nil
}

// The parameters to `UpdateSink`.
type UpdateSinkRequest struct {
	// The resource name of the sink to update.
	// Example: `"projects/my-project-id/sinks/my-sink-id"`.
	//
	// The updated sink must be provided in the request and have the
	// same name that is specified in `sinkName`.  If the sink does not
	// exist, it is created.
	SinkName string `protobuf:"bytes,1,opt,name=sink_name,proto3" json:"sink_name,omitempty"`
	// The updated sink, whose name must be the same as the sink
	// identifier in `sinkName`.  If `sinkName` does not exist, then
	// this method creates a new sink.
	Sink *LogSink `protobuf:"bytes,2,opt,name=sink" json:"sink,omitempty"`
}

func (m *UpdateSinkRequest) Reset()         { *m = UpdateSinkRequest{} }
func (m *UpdateSinkRequest) String() string { return proto.CompactTextString(m) }
func (*UpdateSinkRequest) ProtoMessage()    {}

func (m *UpdateSinkRequest) GetSink() *LogSink {
	if m != nil {
		return m.Sink
	}
	return nil
}

// The parameters to `DeleteSink`.
type DeleteSinkRequest struct {
	// The resource name of the sink to delete.
	// Example: `"projects/my-project-id/sinks/my-sink-id"`.
	SinkName string `protobuf:"bytes,1,opt,name=sink_name,proto3" json:"sink_name,omitempty"`
}

func (m *DeleteSinkRequest) Reset()         { *m = DeleteSinkRequest{} }
func (m *DeleteSinkRequest) String() string { return proto.CompactTextString(m) }
func (*DeleteSinkRequest) ProtoMessage()    {}

func init() {
	proto.RegisterType((*LogSink)(nil), "google.logging.v2.LogSink")
	proto.RegisterType((*ListSinksRequest)(nil), "google.logging.v2.ListSinksRequest")
	proto.RegisterType((*ListSinksResponse)(nil), "google.logging.v2.ListSinksResponse")
	proto.RegisterType((*GetSinkRequest)(nil), "google.logging.v2.GetSinkRequest")
	proto.RegisterType((*CreateSinkRequest)(nil), "google.logging.v2.CreateSinkRequest")
	proto.RegisterType((*UpdateSinkRequest)(nil), "google.logging.v2.UpdateSinkRequest")
	proto.RegisterType((*DeleteSinkRequest)(nil), "google.logging.v2.DeleteSinkRequest")
	proto.RegisterEnum("google.logging.v2.LogSink_VersionFormat", LogSink_VersionFormat_name, LogSink_VersionFormat_value)
}
