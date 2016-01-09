package controller

import (
	"golang.org/x/net/context"
	"k8s.io/kubernetes/pkg/api"
	k8client "k8s.io/kubernetes/pkg/client/unversioned"
)

const namespace = "gke_dev-europe-west1_europe-west1-d_operator"

type apiServer struct {
	client *k8client.Client
}

func newAPIServer(client *k8client.Client) *apiServer {
	return &apiServer{client}
}

func (s *apiServer) CreateCluster(
	context.Context,
	*CreateClusterRequest,
) (*CreateClusterResponse, error) {
	s.client.ReplicationControllers(namespace).Create(&api.ReplicationController{
		ObjectMeta: api.ObjectMeta{
			Name:   "operatord",
			Labels: map[string]string{"app": "operatord"},
		},
		Spec: api.ReplicationControllerSpec{
			Replicas: 1,
			Template: &api.PodTemplateSpec{
				ObjectMeta: api.ObjectMeta{
					Labels: map[string]string{
						"app": "operatord",
					},
				},
				Spec: api.PodSpec{
					Volumes: []api.Volume{
						{
							Name: "secrets",
							VolumeSource: api.VolumeSource{
								Secret: &api.SecretVolumeSource{
									SecretName: "operatord",
								},
							},
						},
					},
					Containers: []api.Container{
						{
							Name:    "operatord",
							Image:   "gcr.io/dev-europe-west1/operatord:f743959",
							Command: []string{"/k8s-operatord"},
							VolumeMounts: []api.VolumeMount{
								{
									Name:      "secrets",
									MountPath: "/secrets",
									ReadOnly:  true,
								},
							},
							Ports: []api.ContainerPort{
								{
									Name:          "operatord",
									HostPort:      3000,
									ContainerPort: 3000,
								},
							},
						},
					},
				},
			},
		},
	})
	return nil, nil
}
