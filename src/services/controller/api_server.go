package controller

import k8client "k8s.io/kubernetes/pkg/client/unversioned"

type apiServer struct {
	client *k8client.Client
}

func newAPIServer(client *k8client.Client) *apiServer {
	return &apiServer{client}
}

func (s *apiServer) CreateCluster(*CreateClusterRequest) (*CreateClusterResponse, error) {
	s.client.ReplicationControllers.Create(&api.ReplicationController{
		Replicas: 1,

		Template: &api.PodTemplateSpec{
			&api.ObjectMeta{
				Labels: map[string]string{
					"app": "operatord",
				},
			},
			&api.PodSpec{
				Volumes: []api.Volumes{
					{
						"secrets",
						api.VolumeSource{
							&api.SecretVolumeSource{
								SecretName: "operatord",
							},
						},
					},
				},
				Containers: []api.Container{
					{
						Name:     "operatord",
						Image:    "gcr.io/dev-europe-west1/operatord:f743959",
						Commands: []string{"/k8s-operatord"},
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
	})
}
