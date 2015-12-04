package gcloud

import (
	"bytes"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"text/tabwriter"

	"github.com/sr/operator/src/proto"

	"golang.org/x/net/context"
	computeapi "google.golang.org/api/compute/v1"
)

type apiServer struct {
	client *http.Client
}

func newAPIServer(client *http.Client) *apiServer {
	return &apiServer{client}
}

func (s *apiServer) ListInstances(
	ctx context.Context,
	request *ListInstancesRequest,
) (*ListInstancesResponse, error) {
	service, err := computeapi.New(s.client)
	if err != nil {
		return nil, err
	}
	response, err := service.Instances.AggregatedList(request.ProjectId).Do()
	if err != nil {
		return nil, err
	}

	var instances []*Instance
	for _, item := range response.Items {
		for _, instance := range item.Instances {
			zoneParts := strings.Split(instance.Zone, "/")
			instances = append(instances, &Instance{
				Id:     string(instance.Id),
				Name:   instance.Name,
				Status: instance.Status,
				Zone:   zoneParts[len(zoneParts)-1],
			})
		}
	}

	output := bytes.NewBufferString("")
	w := new(tabwriter.Writer)
	w.Init(output, 0, 8, 0, '\t', 0)
	fmt.Fprintf(w, "%s\t%s\t%s\n", "NAME", "STATUS", "ZONE")
	for _, instance := range instances {
		fmt.Fprintf(
			w,
			"%s\t%s\t%s\n",
			instance.Name,
			instance.Status,
			instance.Zone,
		)
	}
	w.Flush()

	return &ListInstancesResponse{
		Objects: instances,
		Output:  &proto.Output{PlainText: output.String()},
	}, nil
}

func (s *apiServer) ListOperations(
	ctx context.Context,
	request *ListOperationsRequest,
) (*ListOperationsResponse, error) {
	service, err := computeapi.New(s.client)
	if err != nil {
		return nil, err
	}
	response, err := service.GlobalOperations.AggregatedList(request.ProjectId).Do()
	if err != nil {
		return nil, err
	}
	var operations []*Operation
	for _, item := range response.Items {
		for _, operation := range item.Operations {
			operations = append(operations, &Operation{
				Id:     strconv.FormatUint(operation.Id, 10),
				Type:   string(operation.OperationType),
				Status: string(operation.Status),
			})
		}
	}
	return &ListOperationsResponse{
		Operations: operations,
	}, nil
}
