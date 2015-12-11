package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path"
	"strings"

	"k8s.io/kubernetes/pkg/api"
	"k8s.io/kubernetes/pkg/util/yaml"
)

const (
	templateFileName = "secrets.tmpl.yml"
	secretsFileName  = "secrets.json"
)

var (
	templateFile = flag.String("template", "", "path of the secret file template")
)

func run() error {
	if path.Base(*templateFile) != templateFileName {
		fmt.Errorf("%s is not a secret template", *templateFile)
	}
	file, err := os.Open(*templateFile)
	defer file.Close()
	if err != nil {
		return err
	}
	decoder := yaml.NewYAMLToJSONDecoder(file)
	secret := &api.Secret{}
	if err := decoder.Decode(secret); err != nil {
		return err
	}
	for name, _ := range secret.Data {
		value, ok := os.LookupEnv(name)
		if !ok {
			return fmt.Errorf("environment variable %s must be set", name)
		}
		newValue := bytes.NewBufferString("")
		encoder := base64.NewEncoder(base64.StdEncoding, newValue)
		encoder.Write([]byte(value))
		encoder.Close()
		secret.Data[name] = newValue.Bytes()
	}
	secretFile, err := os.Create(strings.Replace(*templateFile, templateFileName, secretsFileName, 1))
	if err != nil {
		return err
	}
	defer secretFile.Close()
	return json.NewEncoder(secretFile).Encode(secret)
}

func main() {
	flag.Parse()
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "k8s-gen-secrets: %v\n", err)
		os.Exit(1)
	}
}
