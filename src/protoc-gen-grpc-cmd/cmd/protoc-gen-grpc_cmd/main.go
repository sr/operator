package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/golang/protobuf/proto"
	plugin "github.com/golang/protobuf/protoc-gen-go/plugin"
)

func main() {
	data, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		log.Fatal(err, "reading input")
	}

	request := new(plugin.CodeGeneratorRequest)
	response := new(plugin.CodeGeneratorResponse)

	if err := proto.Unmarshal(data, request); err != nil {
		log.Fatal(err)
	}

	if len(request.FileToGenerate) == 0 {
		log.Fatal("no files to generate")
	}

	response.File = make([]*plugin.CodeGeneratorResponse_File, len(request.ProtoFile))

	for i, file := range request.ProtoFile {
		response.File[i] = new(plugin.CodeGeneratorResponse_File)
		response.File[i].Name = proto.String(fmt.Sprintf("hax-%d", i))
		response.File[i].Content = proto.String(fmt.Sprintf("%v", file.Service))
	}

	data, err = proto.Marshal(response)
	if err != nil {
		log.Fatal(err, "failed to marshal output proto")
	}
	_, err = os.Stdout.Write(data)
	if err != nil {
		log.Fatal(err, "failed to write output proto")
	}

	// g.CommandLineParameters(g.Request.GetParameter())

	// // Create a wrapped version of the Descriptors and EnumDescriptors that
	// // point to the file that defines them.
	// g.WrapTypes()

	// g.SetPackageNames()
	// g.BuildTypeNameMap()

	// g.GenerateAllFiles()

	// // Send back the results.
	// data, err = proto.Marshal(g.Response)
	// if err != nil {
	// 	g.Error(err, "failed to marshal output proto")
	// }
	// _, err = os.Stdout.Write(data)
	// if err != nil {
	// 	g.Error(err, "failed to write output proto")
	// }
}
