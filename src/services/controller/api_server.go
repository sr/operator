package controller

import (
	"encoding/base64"
	"fmt"
	"os"
	"strings"

	"operator"

	"golang.org/x/net/context"
	"k8s.io/kubernetes/pkg/api"
	k8client "k8s.io/kubernetes/pkg/client/unversioned"
)

type apiServer struct {
	client    *k8client.Client
	namespace string
	operatord *OperatordConfig
	hubot     *HubotConfig
}

func newAPIServer(
	client *k8client.Client,
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
		Output: &operator.Output{
			PlainText: fmt.Sprintf(
				"replication controllers: operatord=%s hubot=%s",
				s.operatord.Name,
				s.hubot.Name,
			),
		},
	}, nil
}

func (s *apiServer) createOperatordResources() error {
	secret, err := s.client.Secrets(s.namespace).Get(s.operatord.Name)
	if err != nil {
		secret, err = s.createSecret(s.operatord.Name, s.operatord.Secrets)
		if err != nil {
			return err
		}
	}
	_, err = s.client.ReplicationControllers(s.namespace).Get(s.operatord.Name)
	if err != nil {
		_, err := s.client.ReplicationControllers(s.namespace).
			Create(s.getOperatordRC(secret))
		if err != nil {
			return err
		}
	}
	_, err = s.client.Services(s.namespace).Get(s.operatord.Name)
	if err != nil {
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
		secret, err = s.createSecret(s.hubot.Name, s.hubot.Secrets)
		if err != nil {
			return err
		}
	}
	_, err = s.client.ReplicationControllers(s.namespace).Get(s.hubot.Name)
	if err != nil {
		_, err := s.client.ReplicationControllers(s.namespace).
			Create(s.getHubotRC(secret))
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

func encodeSecrets(secrets map[string]string) map[string][]byte {
	encodedSecrets := make(map[string][]byte, len(secrets))
	for name, value := range secrets {
		encoded := make([]byte, base64.StdEncoding.EncodedLen(len(value)))
		base64.StdEncoding.Encode(encoded, []byte(value))
		newName := strings.Replace(strings.ToLower(name), "_", ".", -1)
		encodedSecrets[newName] = encoded
	}
	return encodedSecrets
}

func loadSecretsForService(
	optionName string,
	optionValue string,
) (map[string]string, error) {
	secrets := make(map[string]string)
	for _, secret := range strings.Split(optionValue, ",") {
		value, ok := os.LookupEnv(secret)
		if !ok {
			return nil, fmt.Errorf(
				"env key not set when included in %s: %s",
				optionName,
				optionValue,
			)
		}
		secrets[secret] = value
	}
	return secrets, nil
}
