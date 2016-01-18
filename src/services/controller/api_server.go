package controller

import (
	"encoding/base64"
	"fmt"
	"strings"

	"operator"

	"golang.org/x/net/context"
	"k8s.io/kubernetes/pkg/api"
	k8client "k8s.io/kubernetes/pkg/client/unversioned"
)

type apiServer struct {
	client    *k8client.Client
	namespace string
	secrets   map[string]string
}

func newAPIServer(
	client *k8client.Client,
	namespace string,
	secrets map[string]string,
) *apiServer {
	return &apiServer{client, namespace, secrets}
}

func (s *apiServer) CreateCluster(
	context.Context,
	*CreateClusterRequest,
) (*CreateClusterResponse, error) {
	secret, err := s.client.Secrets(s.namespace).Create(&api.Secret{
		ObjectMeta: api.ObjectMeta{
			Name: "operatord",
		},
		Type: api.SecretTypeOpaque,
		Data: s.encodedSecrets(),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create secret: %v", err)
	}
	replicationController, err := s.client.ReplicationControllers(s.namespace).
		Create(&api.ReplicationController{
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
										SecretName: secret.Name,
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
	if err != nil {
		return nil, fmt.Errorf("failed to create operatord replication controller: %v", err)
	}
	return &CreateClusterResponse{
		Output: &operator.Output{
			PlainText: fmt.Sprintf("replication controller: %s", replicationController.Name),
		},
	}, nil
}

func (s *apiServer) encodedSecrets() map[string][]byte {
	secrets := make(map[string][]byte, len(s.secrets))
	for name, value := range s.secrets {
		encoded := make([]byte, base64.StdEncoding.EncodedLen(len(value)))
		base64.StdEncoding.Encode(encoded, []byte(value))
		newName := strings.Replace(strings.ToLower(name), "_", ".", -1)
		secrets[newName] = encoded
	}
	return secrets
}
