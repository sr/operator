package main

import (
	"bytes"
	"fmt"
	"os"

	"github.com/sr/operator/generator"
)

const (
	programName = "protoc-gen-operatorlocal"
	// TODO(sr) Parameterize this.
	filename = "chatoopslocal-gen.go"
	pkgname  = "chatoopslocal"
)

func generate(descriptor *generator.Descriptor) ([]*generator.File, error) {
	var buffer bytes.Buffer
	data := struct {
		*generator.Descriptor
		LocalPackageName string
	}{
		descriptor,
		pkgname,
	}
	if err := clientTemplate.Execute(&buffer, data); err != nil {
		return nil, err
	}
	return []*generator.File{
		{
			Name:    filename,
			Content: buffer.String(),
		},
	}, nil
}

func main() {
	if err := generator.Compile(os.Stdin, os.Stdout, generate); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s\n", programName, err)
		os.Exit(1)
	}
}
