// Code generated by protoc-gen-go.
// source: google/logging/v2/logging_metrics.proto
// DO NOT EDIT!

package google_logging_v2

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"
import _ "github.com/gengo/grpc-gateway/third_party/googleapis/google/api"
import _ "go.pedge.io/pb/go/google/protobuf"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// Describes a logs-based metric.  The value of the metric is the
// number of log entries that match a logs filter.
type LogMetric struct {
	// Required. The client-assigned metric identifier. Example:
	// `"severe_errors"`.  Metric identifiers are limited to 1000
	// characters and can include only the following characters: `A-Z`,
	// `a-z`, `0-9`, and the special characters `_-.,+!*',()%/\`.  The
	// forward-slash character (`/`) denotes a hierarchy of name pieces,
	// and it cannot be the first character of the name.
	Name string `protobuf:"bytes,1,opt,name=name" json:"name,omitempty"`
	// A description of this metric, which is used in documentation.
	Description string `protobuf:"bytes,2,opt,name=description" json:"description,omitempty"`
	// An [advanced logs filter](/logging/docs/view/advanced_filters).
	// Example: `"logName:syslog AND severity>=ERROR"`.
	Filter string `protobuf:"bytes,3,opt,name=filter" json:"filter,omitempty"`
}

func (m *LogMetric) Reset()                    { *m = LogMetric{} }
func (m *LogMetric) String() string            { return proto.CompactTextString(m) }
func (*LogMetric) ProtoMessage()               {}
func (*LogMetric) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{0} }

// The parameters to ListLogMetrics.
type ListLogMetricsRequest struct {
	// Required. The resource name of the project containing the metrics.
	// Example: `"projects/my-project-id"`.
	ProjectName string `protobuf:"bytes,1,opt,name=project_name" json:"project_name,omitempty"`
	// Optional. If the `pageToken` request parameter is supplied, then the next
	// page of results in the set are retrieved.  The `pageToken` parameter must
	// be set with the value of the `nextPageToken` result parameter from the
	// previous request.  The value of `projectName` must
	// be the same as in the previous request.
	PageToken string `protobuf:"bytes,2,opt,name=page_token" json:"page_token,omitempty"`
	// Optional. The maximum number of results to return from this request.  Fewer
	// results might be returned. You must check for the `nextPageToken` result to
	// determine if additional results are available, which you can retrieve by
	// passing the `nextPageToken` value in the `pageToken` parameter to the next
	// request.
	PageSize int32 `protobuf:"varint,3,opt,name=page_size" json:"page_size,omitempty"`
}

func (m *ListLogMetricsRequest) Reset()                    { *m = ListLogMetricsRequest{} }
func (m *ListLogMetricsRequest) String() string            { return proto.CompactTextString(m) }
func (*ListLogMetricsRequest) ProtoMessage()               {}
func (*ListLogMetricsRequest) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{1} }

// Result returned from ListLogMetrics.
type ListLogMetricsResponse struct {
	// A list of logs-based metrics.
	Metrics []*LogMetric `protobuf:"bytes,1,rep,name=metrics" json:"metrics,omitempty"`
	// If there are more results than were returned, then `nextPageToken` is given
	// a value in the response.  To get the next batch of results, call this
	// method again using the value of `nextPageToken` as `pageToken`.
	NextPageToken string `protobuf:"bytes,2,opt,name=next_page_token" json:"next_page_token,omitempty"`
}

func (m *ListLogMetricsResponse) Reset()                    { *m = ListLogMetricsResponse{} }
func (m *ListLogMetricsResponse) String() string            { return proto.CompactTextString(m) }
func (*ListLogMetricsResponse) ProtoMessage()               {}
func (*ListLogMetricsResponse) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{2} }

func (m *ListLogMetricsResponse) GetMetrics() []*LogMetric {
	if m != nil {
		return m.Metrics
	}
	return nil
}

// The parameters to GetLogMetric.
type GetLogMetricRequest struct {
	// The resource name of the desired metric.
	// Example: `"projects/my-project-id/metrics/my-metric-id"`.
	MetricName string `protobuf:"bytes,1,opt,name=metric_name" json:"metric_name,omitempty"`
}

func (m *GetLogMetricRequest) Reset()                    { *m = GetLogMetricRequest{} }
func (m *GetLogMetricRequest) String() string            { return proto.CompactTextString(m) }
func (*GetLogMetricRequest) ProtoMessage()               {}
func (*GetLogMetricRequest) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{3} }

// The parameters to CreateLogMetric.
type CreateLogMetricRequest struct {
	// The resource name of the project in which to create the metric.
	// Example: `"projects/my-project-id"`.
	//
	// The new metric must be provided in the request.
	ProjectName string `protobuf:"bytes,1,opt,name=project_name" json:"project_name,omitempty"`
	// The new logs-based metric, which must not have an identifier that
	// already exists.
	Metric *LogMetric `protobuf:"bytes,2,opt,name=metric" json:"metric,omitempty"`
}

func (m *CreateLogMetricRequest) Reset()                    { *m = CreateLogMetricRequest{} }
func (m *CreateLogMetricRequest) String() string            { return proto.CompactTextString(m) }
func (*CreateLogMetricRequest) ProtoMessage()               {}
func (*CreateLogMetricRequest) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{4} }

func (m *CreateLogMetricRequest) GetMetric() *LogMetric {
	if m != nil {
		return m.Metric
	}
	return nil
}

// The parameters to UpdateLogMetric.
//
type UpdateLogMetricRequest struct {
	// The resource name of the metric to update.
	// Example: `"projects/my-project-id/metrics/my-metric-id"`.
	//
	// The updated metric must be provided in the request and have the
	// same identifier that is specified in `metricName`.
	// If the metric does not exist, it is created.
	MetricName string `protobuf:"bytes,1,opt,name=metric_name" json:"metric_name,omitempty"`
	// The updated metric, whose name must be the same as the
	// metric identifier in `metricName`. If `metricName` does not
	// exist, then a new metric is created.
	Metric *LogMetric `protobuf:"bytes,2,opt,name=metric" json:"metric,omitempty"`
}

func (m *UpdateLogMetricRequest) Reset()                    { *m = UpdateLogMetricRequest{} }
func (m *UpdateLogMetricRequest) String() string            { return proto.CompactTextString(m) }
func (*UpdateLogMetricRequest) ProtoMessage()               {}
func (*UpdateLogMetricRequest) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{5} }

func (m *UpdateLogMetricRequest) GetMetric() *LogMetric {
	if m != nil {
		return m.Metric
	}
	return nil
}

// The parameters to DeleteLogMetric.
type DeleteLogMetricRequest struct {
	// The resource name of the metric to delete.
	// Example: `"projects/my-project-id/metrics/my-metric-id"`.
	MetricName string `protobuf:"bytes,1,opt,name=metric_name" json:"metric_name,omitempty"`
}

func (m *DeleteLogMetricRequest) Reset()                    { *m = DeleteLogMetricRequest{} }
func (m *DeleteLogMetricRequest) String() string            { return proto.CompactTextString(m) }
func (*DeleteLogMetricRequest) ProtoMessage()               {}
func (*DeleteLogMetricRequest) Descriptor() ([]byte, []int) { return fileDescriptor3, []int{6} }

func init() {
	proto.RegisterType((*LogMetric)(nil), "google.logging.v2.LogMetric")
	proto.RegisterType((*ListLogMetricsRequest)(nil), "google.logging.v2.ListLogMetricsRequest")
	proto.RegisterType((*ListLogMetricsResponse)(nil), "google.logging.v2.ListLogMetricsResponse")
	proto.RegisterType((*GetLogMetricRequest)(nil), "google.logging.v2.GetLogMetricRequest")
	proto.RegisterType((*CreateLogMetricRequest)(nil), "google.logging.v2.CreateLogMetricRequest")
	proto.RegisterType((*UpdateLogMetricRequest)(nil), "google.logging.v2.UpdateLogMetricRequest")
	proto.RegisterType((*DeleteLogMetricRequest)(nil), "google.logging.v2.DeleteLogMetricRequest")
}

var fileDescriptor3 = []byte{
	// 512 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x09, 0x6e, 0x88, 0x02, 0xff, 0x94, 0x94, 0x4d, 0x6f, 0xd3, 0x40,
	0x10, 0x86, 0xe5, 0x96, 0x06, 0x65, 0x1a, 0x35, 0x74, 0x4b, 0x4d, 0x30, 0x3d, 0x20, 0x1f, 0x20,
	0x84, 0xc6, 0x16, 0x2e, 0x5c, 0x8a, 0xe0, 0xc0, 0x87, 0xb8, 0x14, 0x09, 0xf1, 0x75, 0x01, 0x29,
	0x38, 0xee, 0xd4, 0x5a, 0x48, 0xbc, 0xc6, 0xbb, 0x8d, 0xf8, 0x10, 0x17, 0x6e, 0x9c, 0x91, 0x40,
	0xfc, 0x2e, 0xfe, 0x02, 0x7f, 0x82, 0x1b, 0x9b, 0xf5, 0xba, 0x31, 0xce, 0xaa, 0x89, 0x6f, 0x5e,
	0xef, 0xf8, 0x9d, 0x67, 0xde, 0x79, 0x65, 0xb8, 0x1a, 0x33, 0x16, 0x8f, 0xd0, 0x1f, 0xb1, 0x38,
	0xa6, 0x49, 0xec, 0x4f, 0x82, 0xe2, 0x71, 0x30, 0x46, 0x91, 0xd1, 0x88, 0x7b, 0x69, 0xc6, 0x04,
	0x23, 0x9b, 0x79, 0xa1, 0xa7, 0x6f, 0xbd, 0x49, 0xe0, 0xec, 0xe8, 0x6f, 0xc3, 0x94, 0xfa, 0x61,
	0x92, 0x30, 0x11, 0x0a, 0xca, 0x12, 0xfd, 0x81, 0x73, 0x49, 0xdf, 0xaa, 0xd3, 0xf0, 0xf8, 0xc8,
	0xc7, 0x71, 0x2a, 0x3e, 0xe6, 0x97, 0xee, 0x5d, 0x68, 0x1e, 0xb0, 0xf8, 0xb1, 0xea, 0x40, 0x5a,
	0x70, 0x26, 0x09, 0xc7, 0xd8, 0xb1, 0x2e, 0x5b, 0xdd, 0x26, 0xd9, 0x82, 0xf5, 0x43, 0xe4, 0x51,
	0x46, 0xd3, 0xa9, 0x5a, 0x67, 0x45, 0xbd, 0xdc, 0x80, 0xc6, 0x11, 0x1d, 0x09, 0xcc, 0x3a, 0xab,
	0xd3, 0xb3, 0xfb, 0x1c, 0xb6, 0x0f, 0x28, 0x17, 0x27, 0x1a, 0xfc, 0x29, 0xbe, 0x3f, 0x46, 0x2e,
	0xc8, 0x79, 0x68, 0xc9, 0x0e, 0x6f, 0x31, 0x12, 0x83, 0x92, 0x26, 0x01, 0x48, 0xc3, 0x18, 0x07,
	0x82, 0xbd, 0xc3, 0x42, 0x72, 0x13, 0x9a, 0xea, 0x1d, 0xa7, 0x9f, 0x50, 0xa9, 0xae, 0xb9, 0x6f,
	0xc0, 0xae, 0xaa, 0xf2, 0x54, 0x4e, 0x84, 0xa4, 0x0f, 0x67, 0xb5, 0x1d, 0x52, 0x71, 0xb5, 0xbb,
	0x1e, 0xec, 0x78, 0x73, 0x7e, 0x78, 0xb3, 0x89, 0x2e, 0x40, 0x3b, 0xc1, 0x0f, 0x62, 0x50, 0x6d,
	0xea, 0xf6, 0x60, 0xeb, 0x11, 0xce, 0x1a, 0x14, 0xd4, 0x72, 0xe6, 0x5c, 0xbe, 0x04, 0xed, 0xbe,
	0x06, 0xfb, 0x7e, 0x86, 0xa1, 0xc0, 0xb9, 0x72, 0xf3, 0x90, 0xbb, 0xd0, 0xc8, 0x45, 0x54, 0xaf,
	0x05, 0x88, 0xee, 0x2b, 0xb0, 0x5f, 0xa4, 0x87, 0x26, 0x75, 0x13, 0x4c, 0x4d, 0xf1, 0x3e, 0xd8,
	0x0f, 0x70, 0x84, 0x4b, 0x8a, 0x07, 0x7f, 0xd7, 0xe0, 0x9c, 0x76, 0xfc, 0x19, 0x66, 0x13, 0x1a,
	0xe1, 0xcb, 0x80, 0xfc, 0xb2, 0x60, 0xe3, 0xff, 0x6d, 0x90, 0xae, 0xa9, 0xa9, 0x29, 0x06, 0xce,
	0xb5, 0x25, 0x2a, 0xf3, 0xd5, 0xba, 0xc1, 0xd7, 0xdf, 0x7f, 0xbe, 0xaf, 0xec, 0x92, 0x9e, 0xcc,
	0xfe, 0x10, 0x45, 0x78, 0xc3, 0xff, 0x5c, 0x36, 0xf7, 0x8e, 0x3e, 0x70, 0xbf, 0xf7, 0xc5, 0xd7,
	0x19, 0x20, 0xdf, 0x2c, 0x68, 0x95, 0xf7, 0x48, 0xae, 0x18, 0xfa, 0x19, 0x16, 0xed, 0x9c, 0x6e,
	0xdb, 0x9e, 0x42, 0xe9, 0x93, 0xeb, 0x33, 0x94, 0x92, 0x59, 0x25, 0x92, 0x02, 0x44, 0x32, 0x91,
	0x1f, 0x16, 0xb4, 0x2b, 0x39, 0x21, 0xa6, 0xf1, 0xcd, 0x59, 0x5a, 0x40, 0xb4, 0xaf, 0x88, 0x6e,
	0xba, 0x35, 0xcc, 0xd9, 0xd7, 0x41, 0x21, 0x3f, 0x25, 0x58, 0x25, 0x62, 0x46, 0x30, 0x73, 0x0c,
	0x17, 0x80, 0xdd, 0x56, 0x60, 0xb7, 0x9c, 0x3a, 0x56, 0x9d, 0x90, 0xc9, 0xf5, 0xb5, 0x2b, 0xf9,
	0x34, 0x92, 0x99, 0x33, 0xec, 0xd8, 0x45, 0x69, 0xf1, 0x6b, 0xf3, 0x1e, 0x4e, 0x7f, 0x6d, 0xc5,
	0xfa, 0x7a, 0x75, 0x98, 0xee, 0x5d, 0x84, 0xed, 0x88, 0x8d, 0xe7, 0x9b, 0x3f, 0xb1, 0x86, 0x0d,
	0xa5, 0xbf, 0xf7, 0x2f, 0x00, 0x00, 0xff, 0xff, 0x73, 0x3c, 0x24, 0x8a, 0xa4, 0x05, 0x00, 0x00,
}
