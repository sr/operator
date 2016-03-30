package gcloud

import (
	"bytes"
	"fmt"
	"net/http"
	"strings"
	"time"

	"text/tabwriter"

	"github.com/sr/operator"
	"golang.org/x/net/context"
	compute "google.golang.org/api/compute/v1"
)

const (
	// Gives instance full access to all Google Cloud services
	cloudPlatformScope = "https://www.googleapis.com/auth/cloud-platform"
	startupScriptKey   = "startup-script"
)

type apiServer struct {
	config         *Env
	client         *http.Client
	computeService *compute.Service
	startupScript  string
}

func newAPIServer(
	config *Env,
	client *http.Client,
	computeService *compute.Service,
	startupScript string,
) *apiServer {
	return &apiServer{
		config,
		client,
		computeService,
		startupScript,
	}
}

func (s *apiServer) CreateDevInstance(
	ctx context.Context,
	request *CreateDevInstanceRequest,
) (*CreateDevInstanceResponse, error) {
	zone, err := s.computeService.Zones.Get(s.config.ProjectID,
		s.config.DefaultZone).Do()
	if err != nil {
		return nil, err
	}
	image, err := s.computeService.Images.Get(s.config.ProjectID,
		s.config.DefaultImage).Do()
	if err != nil {
		return nil, err
	}
	machineType, err := s.computeService.MachineTypes.Get(s.config.ProjectID,
		zone.Name, s.config.DefaultMachineType).Do()
	if err != nil {
		return nil, err
	}
	network, err := s.computeService.Networks.Get(s.config.ProjectID,
		s.config.DefaultNetwork).Do()
	if err != nil {
		return nil, err
	}
	operation, err := s.computeService.Instances.Insert(
		s.config.ProjectID,
		s.config.DefaultZone,
		&compute.Instance{
			Name:        fmt.Sprintf("dev-%v", time.Now().Unix()),
			MachineType: machineType.SelfLink,
			Metadata: &compute.Metadata{
				Items: []*compute.MetadataItems{
					{
						Key:   startupScriptKey,
						Value: &s.startupScript,
					},
				},
			},
			Disks: []*compute.AttachedDisk{
				{
					Type:       "PERSISTENT",
					Mode:       "READ_WRITE",
					Kind:       "compute#attachedDisk",
					Boot:       true,
					AutoDelete: true,
					InitializeParams: &compute.AttachedDiskInitializeParams{
						SourceImage: image.SelfLink,
						DiskSizeGb:  image.DiskSizeGb,
						DiskType:    fmt.Sprintf("zones/%s/diskTypes/%s", zone.Name, "pd-standard"),
					},
				},
			},
			NetworkInterfaces: []*compute.NetworkInterface{
				{
					Network: network.SelfLink,
					AccessConfigs: []*compute.AccessConfig{
						{
							Type: "ONE_TO_ONE_NAT",
						},
					},
				},
			},
			ServiceAccounts: []*compute.ServiceAccount{
				{
					Email:  s.config.ServiceAccountEmail,
					Scopes: []string{cloudPlatformScope},
				},
			},
		}).Context(ctx).Do()
	if err != nil {
		return nil, err
	}
	return &CreateDevInstanceResponse{
		Output: &operator.Output{PlainText: operation.SelfLink},
	}, nil
}

func (s *apiServer) ListInstances(
	ctx context.Context,
	request *ListInstancesRequest,
) (*ListInstancesResponse, error) {
	if request.ProjectId == "" {
		return nil, operator.NewArgumentRequiredError("ProjectId")
	}
	response, err := s.computeService.Instances.AggregatedList(request.ProjectId).Do()
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
	if err := w.Flush(); err != nil {
		return nil, err
	}
	return &ListInstancesResponse{
		Objects: instances,
		Output:  &operator.Output{PlainText: output.String()},
	}, nil
}

func (s *apiServer) Stop(
	ctx context.Context,
	request *StopRequest,
) (*StopResponse, error) {
	if request.Zone == "" {
		return nil, operator.NewArgumentRequiredError("Zone")
	}
	if request.Instance == "" {
		return nil, operator.NewArgumentRequiredError("Instance")
	}
	_, err := s.computeService.Instances.Stop(
		s.config.ProjectID,
		request.Zone,
		request.Instance,
	).Do()
	if err != nil {
		return nil, err
	}
	return &StopResponse{
		Output: &operator.Output{
			PlainText: "OK",
		},
	}, nil
}
