package gcloud

import (
	"bytes"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"text/tabwriter"

	"github.com/jmcvetta/randutil"
	"github.com/sr/operator"
	"golang.org/x/net/context"
	compute "google.golang.org/api/compute/v1"
	container "google.golang.org/api/container/v1"
	logging "google.golang.org/api/logging/v1beta3"
)

const (
	// TODO(sr) Kill container cluster stuff?
	clusterAdminUsername = "admin"
	loggingService       = "logging.googleapis.com"
	// TODO(sr) Get service account email via instance metadata API
	// curl -H "Metadata-Flavor: Google" "http://metadata/computeMetadata/v1/instance/service-accounts
	serviceAccountEmail = "467917727604-compute@developer.gserviceaccount.com"
	// TODO(sr) Make this configurable via Config
	defaultZone = "europe-west1-d"
	// TODO(sr) Make this configurable via Config. Rename to defaultProjectId
	projectId = "babelstoemp"
	// TODO(sr) Make this configurable via Config + request param
	// TODO(sr) provide map with small = g1-small medium = n1-standard-1 large = n1-standard-2
	defaultMachineType = "g1-small"
	// TODO(sr) Make this automatic (Name + timestamp or something)
	defaultInstanceName = "dev2"
	// TODO(sr) Make this configurable via Config + request param
	// TODO(sr) Allow getting a list of custom images
	defaultImageName   = "dev-1457636147"
	defaultNetworkName = "default"
	// Gives instance full access to all Google Cloud services
	cloudPlatformScope = "https://www.googleapis.com/auth/cloud-platform"
	startupScriptKey   = "startup-script"

	userAccountScope   = "https://www.googleapis.com/auth/cloud.useraccounts"
	userInfoEmailScope = "https://www.googleapis.com/auth/userinfo.email"
)

var oauthScopes = []string{
	compute.CloudPlatformScope,
	compute.ComputeScope,
	compute.DevstorageReadWriteScope,
	logging.LoggingAdminScope,
	userAccountScope,
	userInfoEmailScope,
}
var startupScriptValue = "#!bin/sh\necho boom"

type apiServer struct {
	client           *http.Client
	computeService   *compute.Service
	containerService *container.Service
}

func newAPIServer(
	client *http.Client,
	computeService *compute.Service,
	containerService *container.Service,
) *apiServer {
	return &apiServer{
		client,
		computeService,
		containerService,
	}
}

func (s *apiServer) CreateContainerCluster(
	ctx context.Context,
	request *CreateContainerClusterRequest,
) (*CreateContainerClusterResponse, error) {
	nodeCount, err := strconv.ParseInt(request.NodeCount, 10, 64)
	if err != nil {
		return nil, fmt.Errorf("invalid node count value: %v", request.NodeCount)
	}
	password, err := randutil.String(10, randutil.Alphanumeric)
	if err != nil {
		return nil, errors.New("failed to generated password")
	}
	operation, err := s.containerService.Projects.Zones.Clusters.Create(
		request.ProjectId,
		request.Zone,
		&container.CreateClusterRequest{
			Cluster: &container.Cluster{
				Name:             request.Name,
				InitialNodeCount: nodeCount,
				LoggingService:   loggingService,
				MasterAuth: &container.MasterAuth{
					Username: clusterAdminUsername,
					Password: password,
				},
				NodeConfig: &container.NodeConfig{
					MachineType: defaultMachineType,
					OauthScopes: oauthScopes,
				},
			},
		},
	).Do()
	if err != nil {
		return nil, err
	}
	return &CreateContainerClusterResponse{
		Output: &operator.Output{PlainText: operation.SelfLink},
	}, nil
}

func (s *apiServer) CreateDevInstance(
	ctx context.Context,
	request *CreateDevInstanceRequest,
) (*CreateDevInstanceResponse, error) {
	zone, err := s.computeService.Zones.Get(projectId, defaultZone).Do()
	if err != nil {
		return nil, err
	}
	image, err := s.computeService.Images.Get(projectId, defaultImageName).Do()
	if err != nil {
		return nil, err
	}
	machineType, err := s.computeService.MachineTypes.Get(projectId, zone.Name, defaultMachineType).Do()
	if err != nil {
		return nil, err
	}
	network, err := s.computeService.Networks.Get(projectId, defaultNetworkName).Do()
	if err != nil {
		return nil, err
	}
	op, err := s.computeService.Instances.Insert(projectId, defaultZone,
		&compute.Instance{
			Name:        defaultInstanceName,
			MachineType: machineType.SelfLink,
			Metadata: &compute.Metadata{
				Items: []*compute.MetadataItems{
					{
						Key:   startupScriptKey,
						Value: &startupScriptValue,
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
					Email:  serviceAccountEmail,
					Scopes: []string{cloudPlatformScope},
				},
			},
		}).Context(ctx).Do()
	if err != nil {
		return nil, err
	}
	return &CreateDevInstanceResponse{
		Output: &operator.Output{PlainText: op.SelfLink},
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
