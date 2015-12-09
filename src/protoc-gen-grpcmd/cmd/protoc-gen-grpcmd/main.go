package main

import (
	"io/ioutil"
	"os"
	"regexp"
	"strings"

	"github.com/gogo/protobuf/proto"
	"github.com/gogo/protobuf/protoc-gen-gogo/generator"
	"github.com/sr/operator/src/protoc-gen-grpcmd"
)

func main() {
	gen := generator.New()

	data, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		gen.Error(err, "reading input")
	}

	if err := proto.Unmarshal(data, gen.Request); err != nil {
		gen.Error(err, "parsing input proto")
	}

	if len(gen.Request.FileToGenerate) == 0 {
		gen.Fail("no files to generate")
	}

	gen.CommandLineParameters(gen.Request.GetParameter())

	gen.WrapTypes()
	gen.SetPackageNames()
	gen.BuildTypeNameMap()
	gen.GeneratePlugin(cmd.New())

	r := regexp.MustCompile(`package \w+`)

	for i := 0; i < len(gen.Response.File); i++ {
		defaultPath := *gen.Response.File[i].Name
		parts := strings.Split(defaultPath, "/")
		defaultFileName := parts[len(parts)-1]
		newPath := strings.Replace(defaultPath, defaultFileName, "main-gen.go", 1)
		gen.Response.File[i].Name = proto.String(newPath)

		origContent := *gen.Response.File[i].Content
		newPackage := "package main"
		newContent := r.ReplaceAllLiteralString(origContent, newPackage)
		gen.Response.File[i].Content = proto.String(newContent)
	}

	// Send back the results.
	data, err = proto.Marshal(gen.Response)
	if err != nil {
		gen.Error(err, "failed to marshal output proto")
	}
	_, err = os.Stdout.Write(data)
	if err != nil {
		gen.Error(err, "failed to write output proto")
	}
}
