package controller

import client "k8s.io/kubernetes/pkg/client/unversioned"

type Config struct {
	KubernetesHost     string `env:"CONTROLLER_KUBERNETES_HOST,required"`
	KubernetesUsername string `env:"CONTROLLER_KUBERNETES_USERNAME,required"`
	KubernetesPassword string `env:"CONTROLLER_KUBERNETES_PASSWORD,required"`
}

func NewAPIServer(config *Config) (ControllerServer, error) {
	client, err := client.New(&client.Config{
		Host:     config.KubernetesHost,
		Username: config.KubernetesUsername,
		Password: config.KubernetesPassword,
	})
	if err != nil {
		return nil, err
	}
	return newAPIServer(client), nil
}
