package privet

import (
	"fmt"
	"os"
)

func retrieveEnvVars(envVars []string) []string {
	result := make([]string, 0, len(envVars))
	for _, key := range envVars {
		result = append(result, fmt.Sprintf("%s=%s", key, os.Getenv(key)))
	}
	return result
}
