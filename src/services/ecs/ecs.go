package service_ecs

import (
	"github.com/aws/aws-sdk-go/service/ecs"
	"golang.org/x/net/context"
)

type Server struct {
	client *ecs.ECS
}

func NewServer() *Server {
	return &Server{ecs.New(nil)}
}

func (s *Server) ListClusters(
	context context.Context,
	request *ListClustersRequest,
) (*ListClustersResponse, error) {
	var clustersARNs []*string
	err := s.client.ListClustersPages(
		&ecs.ListClustersInput{},
		func(p *ecs.ListClustersOutput, last bool) bool {
			for _, clusterARN := range p.ClusterARNs {
				clustersARNs = append(clustersARNs, clusterARN)
			}
			return true
		},
	)
	if err != nil {
		return nil, err
	}

	describeClustersOutput, err := s.client.DescribeClusters(
		&ecs.DescribeClustersInput{Clusters: clustersARNs},
	)
	if err != nil {
		return nil, err
	}
	response := &ListClustersResponse{}
	for _, cluster := range describeClustersOutput.Clusters {
		status := ClusterStatus_value[*cluster.Status]
		response.Clusters = append(response.Clusters, &Cluster{
			Arn:                 *cluster.ClusterARN,
			Name:                *cluster.ClusterName,
			Status:              ClusterStatus(status),
			ActiveServices:      *cluster.ActiveServicesCount,
			RegisteredInstances: *cluster.RegisteredContainerInstancesCount,
			PendingTasks:        *cluster.PendingTasksCount,
			RunningTasks:        *cluster.RunningTasksCount,
		})
	}
	for _, failure := range describeClustersOutput.Failures {
		response.Errors = append(response.Errors, &Error{
			Arn:     *failure.ARN,
			Message: *failure.Reason,
		})
	}
	return response, nil
}

func (s *Server) ListClusterInstances(
	context context.Context,
	request *ListClusterInstancesRequest,
) (*ListClusterInstancesResponse, error) {
	return &ListClusterInstancesResponse{}, nil
}
