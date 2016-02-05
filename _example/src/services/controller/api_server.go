package controller

import (
	"fmt"

	"github.com/sr/operator/pb"
	"golang.org/x/net/context"
	"k8s.io/kubernetes/pkg/api"
	errors "k8s.io/kubernetes/pkg/api/errors"
	client "k8s.io/kubernetes/pkg/client/unversioned"
)

type apiServer struct {
	client    *client.Client
	namespace string
	operatord *OperatordConfig
	hubot     *HubotConfig
}

func newAPIServer(
	client *client.Client,
	namespace string,
	operatord *OperatordConfig,
	hubot *HubotConfig,
) *apiServer {
	return &apiServer{
		client,
		namespace,
		operatord,
		hubot,
	}
}

func (s *apiServer) CreateCluster(
	ctx context.Context,
	request *CreateClusterRequest,
) (*CreateClusterResponse, error) {
	if err := s.createOperatordResources(); err != nil {
		return nil, fmt.Errorf("failed to create operatord resources: %v", err)
	}
	if err := s.createHubotResources(); err != nil {
		return nil, fmt.Errorf("failed to create hubot resources: %v", err)
	}
	return &CreateClusterResponse{
		Output: &pb.Output{
			PlainText: fmt.Sprintf(
				"replication controllers: operatord=%s hubot=%s",
				s.operatord.Name,
				s.hubot.Name,
			),
		},
	}, nil
}

func (s *apiServer) Deploy(
	ctx context.Context,
	request *DeployRequest,
) (*DeployResponse, error) {
	if request.BuildId == "" {
		return nil, operator.NewArgumentRequiredError("BuildId")
	}
	hubotImage := getImage(s.hubot.Image, request.BuildId)
	operatordImage := getImage(s.operatord.Image, request.BuildId)
	hubotRC, err := s.replicationControllers().Get(s.hubot.Name)
	if err != nil {
		return nil, fmt.Errorf("could not fetch hubot replication controller: %v", err)
	}
	operatordRC, err := s.replicationControllers().Get(s.operatord.Name)
	if err != nil {
		return nil, fmt.Errorf("could not fetch operatord replication controller: %v", err)
	}
	hubotRC.Spec.Replicas = 0
	operatordRC.Spec.Replicas = 0
	if _, err := s.replicationControllers().Update(hubotRC); err != nil {
		return nil, fmt.Errorf("failed to shut down hubot: %v", err)
	}
	if _, err := s.replicationControllers().Update(operatordRC); err != nil {
		return nil, fmt.Errorf("failed to shut down operatord: %v", err)
	}
	hubotRC, err = s.replicationControllers().Get(s.hubot.Name)
	if err != nil {
		return nil, fmt.Errorf("could not fetch updated hubot replication controller: %v", err)
	}
	operatordRC, err = s.replicationControllers().Get(s.operatord.Name)
	if err != nil {
		return nil, fmt.Errorf("could not fetch updated operatord replication controller: %v", err)
	}
	hubotRC.Spec.Replicas = 1
	hubotRC.Spec.Template.Spec.Containers[0].Image = hubotImage
	operatordRC.Spec.Replicas = 1
	operatordRC.Spec.Template.Spec.Containers[0].Image = operatordImage
	if _, err := s.replicationControllers().Update(hubotRC); err != nil {
		return nil, fmt.Errorf("failed to deploy hubot: %v", err)
	}
	if _, err := s.replicationControllers().Update(operatordRC); err != nil {
		return nil, fmt.Errorf("failed to deploy operatord: %v", err)
	}
	return &DeployResponse{
		Output: &pb.Output{
			PlainText: fmt.Sprintf(
				"deployed hubot=%s operatord=%s",
				hubotImage,
				operatordImage,
			),
		},
	}, nil
}

func (s *apiServer) createOperatordResources() error {
	secret, err := s.client.Secrets(s.namespace).Get(s.operatord.Name)
	if err != nil {
		if !errors.IsNotFound(err) {
			return err
		}
		secret, err = s.createSecret(s.operatord.Name, s.operatord.Secrets)
		if err != nil {
			return err
		}
	}
	_, err = s.replicationControllers().Get(s.operatord.Name)
	if err != nil {
		if !errors.IsNotFound(err) {
			return err
		}
		_, err := s.replicationControllers().Create(s.getOperatordRC(secret))
		if err != nil {
			return err
		}
	}
	_, err = s.client.Services(s.namespace).Get(s.operatord.Name)
	if err != nil {
		if !errors.IsNotFound(err) {
			return err
		}
		_, err := s.client.Services(s.namespace).Create(s.getOperatordService())
		if err != nil {
			return err
		}
	}
	return nil
}

func (s *apiServer) createHubotResources() error {
	secret, err := s.client.Secrets(s.namespace).Get(s.hubot.Name)
	if err != nil {
		if !errors.IsNotFound(err) {
			return err
		}
		secret, err = s.createSecret(s.hubot.Name, s.hubot.Secrets)
		if err != nil {
			return err
		}
	}
	_, err = s.replicationControllers().Get(s.hubot.Name)
	if err != nil {
		if !errors.IsNotFound(err) {
			return err
		}
		_, err := s.replicationControllers().Create(s.getHubotRC(secret))
		if err != nil {
			return err
		}
	}
	return nil
}

func (s *apiServer) createSecret(
	name string,
	secrets map[string]string,
) (*api.Secret, error) {
	return s.client.Secrets(s.namespace).Create(&api.Secret{
		ObjectMeta: api.ObjectMeta{Name: name},
		Type:       api.SecretTypeOpaque,
		Data:       encodeSecrets(secrets),
	})
}

func (s *apiServer) replicationControllers() client.ReplicationControllerInterface {
	return s.client.ReplicationControllers(s.namespace)
}
