package controller

import client "k8s.io/kubernetes/pkg/client/unversioned"

const (
	OperatordName           = "operatord"
	OperatordImage          = "gcr.io/dev-europe-west1/operatord:f743959"
	OperatordCommand        = "/k8s-operatord"
	OperatordPortName       = "grpc"
	OperatordPort           = 3000
	OperatordSecretsSetting = "CONTROLLER_OPERATORD_SECRETS"

	HubotName           = "hubot"
	HubotImage          = "gcr.io/dev-europe-west1/hubot:cbc02ba"
	HubotCommand        = "/hubot/bin/k8s-hubot"
	HubotSecretsSetting = "CONTROLLER_HUBOT_SECRETS"
)

/// TODO(sr) rename all Env structs to Config
type Env struct {
	KubectlProxyURL     string `env:"CONTROLLER_KUBECTL_PROXY_URL,required"`
	KubernetesNamespace string `env:"CONTROLLER_KUBERNETES_NAMESPACE,required"`
	OperatordSecrets    string `env:"CONTROLLER_OPERATORD_SECRETS,required"`
	HubotSecrets        string `env:"CONTROLLER_HUBOT_SECRETS,required"`
}

type OperatordConfig struct {
	Name         string
	DefaultImage string
	Command      string
	Port         int
	PortName     string
	Secrets      map[string]string
}

type HubotConfig struct {
	Name         string
	DefaultImage string
	Command      string
	Secrets      map[string]string
}

func NewAPIServer(config *Env) (ControllerServer, error) {
	operatordSecrets, err := loadSecretsForService(
		OperatordSecretsSetting,
		config.OperatordSecrets,
	)
	if err != nil {
		return nil, err
	}
	hubotSecrets, err := loadSecretsForService(
		HubotSecretsSetting,
		config.HubotSecrets,
	)
	if err != nil {
		return nil, err
	}
	client, err := client.New(&client.Config{
		Host: config.KubectlProxyURL,
	})
	if err != nil {
		return nil, err
	}
	return newAPIServer(
		client,
		config.KubernetesNamespace,
		&OperatordConfig{
			Name:         OperatordName,
			DefaultImage: OperatordImage,
			Command:      OperatordCommand,
			PortName:     OperatordPortName,
			Port:         OperatordPort,
			Secrets:      operatordSecrets,
		},
		&HubotConfig{
			Name:         HubotName,
			DefaultImage: HubotImage,
			Command:      HubotCommand,
			Secrets:      hubotSecrets,
		},
	), nil
}
