package controller

import (
	"fmt"
	"os"
	"strings"

	client "k8s.io/kubernetes/pkg/client/unversioned"
)

/// TODO(sr) rename all Env structs to Config
type Env struct {
	KubectlProxyURL     string `env:"CONTROLLER_KUBECTL_PROXY_URL,required"`
	KubernetesNamespace string `env:"CONTROLLER_KUBERNETES_NAMESPACE,required"`
	Secrets             string `env:"CONTROLLER_SECRETS"`
}

func NewAPIServer(config *Env) (ControllerServer, error) {
	secrets := make(map[string]string)
	if config.Secrets != "" {
		for _, secret := range strings.Split(config.Secrets, ",") {
			value, ok := os.LookupEnv(secret)
			if !ok {
				return nil, fmt.Errorf("env key not set when included in CONTROLLER_SECRETS: %s", secret)
			}
			secrets[secret] = value
		}
	}
	client, err := client.New(&client.Config{
		Host: config.KubectlProxyURL,
	})
	if err != nil {
		return nil, err
	}
	return newAPIServer(client, config.KubernetesNamespace, secrets), nil
}
