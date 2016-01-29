package controller

import (
	"encoding/base64"
	"fmt"
	"os"
	"strings"

	"github.com/docker/docker/pkg/parsers"
)

func getImage(image string, tag string) string {
	repo, _ := parsers.ParseRepositoryTag(image)
	return fmt.Sprintf("%s:%s", repo, tag)
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
