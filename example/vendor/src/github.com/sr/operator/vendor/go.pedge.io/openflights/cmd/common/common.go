package common

import (
	"bytes"
	"go/format"
	"io"
	"os"
	"text/template"
)

// WriteData writes generated data out. Internal use only.
func WriteData(pkg string, outFilePath string, tmpl *template.Template, data interface{}) (retErr error) {
	buffer := bytes.NewBuffer(nil)
	metadata := getMetadata(pkg, data)
	if err := tmpl.Execute(buffer, metadata); err != nil {
		return err
	}
	formatted, err := format.Source(buffer.Bytes())
	if err != nil {
		return err
	}
	file, err := os.Create(outFilePath)
	if err != nil {
		return err
	}
	defer func() {
		if err := file.Close(); err != nil && retErr == nil {
			retErr = err
		}
	}()
	if _, err := io.Copy(file, bytes.NewReader(formatted)); err != nil {
		return err
	}
	return nil
}

type metadata struct {
	Import        string
	Package       string
	PackagePrefix string
	Private       bool
	Data          interface{}
}

func getMetadata(pkg string, data interface{}) *metadata {
	metadata := &metadata{
		Package: pkg,
		Data:    data,
	}
	if pkg != "openflights" {
		metadata.Import = "\n import \"go.pedge.io/openflights\""
		metadata.PackagePrefix = "openflights."
	} else {
		metadata.Private = true
	}
	return metadata
}
