/*
Package protoeasy is intended to make using protoc simpler.

Protoeasy compiles all protocol buffer files in a directory/subdirectories,
taking care of all include directories, takes care of gRPC compilation,
and take care of package import modifiers for Golang.

Protoeasy also provides a client/server model where compilation is delegated
to a server process meant to be run in a Docker container. This allows you
to not have to install protoc, gRPC, and associated protoc plugins on your
local development machine.

See the README.md file for more details.
*/
package protoeasy // import "go.pedge.io/protoeasy"

import (
	"fmt"
	"strconv"
	"strings"
)

var (
	//DefaultServerCompiler is the default Compiler for a server.
	DefaultServerCompiler = NewServerCompiler(CompilerOptions{})
	// DefaultAPIServer is the default API Server.
	DefaultAPIServer = NewAPIServer(DefaultServerCompiler, APIServerOptions{})
	// DefaultClientCompiler is the default Compiler for a client.
	DefaultClientCompiler = NewClientCompiler(
		NewLocalAPIClient(
			NewAPIServer(
				DefaultServerCompiler,
				APIServerOptions{
					NoLogging: true,
				},
			),
		),
		CompilerOptions{},
	)
	// DefaultDescriptorSetFileName is the default descriptor set file name.
	DefaultDescriptorSetFileName = "descriptor-set.pb"
	// DefaultFileCompileOptionsFile is the default file to get FileCompileOptions from.
	DefaultFileCompileOptionsFile = "protoeasy.yaml"
	// FileCompileOptionsVersionToCompileOptionsFunc is a map from FileCompileOptions version to CompileOptions converter function.
	FileCompileOptionsVersionToCompileOptionsFunc = map[string]func(*FileCompileOptions) (*CompileOptions, error){
		"v1": toCompileOptionsV1,
	}
)

// FileCompileOptions are CompileOptions with JSON and YAML tags ready to be read from a file.
type FileCompileOptions struct {
	Version string   `json:"version,omitempty" yaml:"version,omitempty"`
	Dir     string   `json:"dir,omitempty" yaml:"dir,omitempty"`
	Plugins []string `json:"plugins,omitempty" yaml:"plugins,omitempty"`
	Options struct {
		NoDefaultIncludes bool     `json:"no_default_includes,omitempty" yaml:"no_default_includes,omitempty"`
		Exclude           []string `json:"exclude,omitempty" yaml:"exclude,omitempty"`
		RelContext        string   `json:"rel_context,omitempty" yaml:"rel_context,omitempty"`
		Grpc              struct{} `json:"grpc,omitempty" yaml:"grpc,omitempty"`
		GrpcGateway       struct{} `json:"grpc_gateway,omitempty" yaml:"grpc_gateway,omitempty"`
		Cpp               struct {
			RelOut string `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
		} `json:"cpp,omitempty" yaml:"cpp,omitempty"`
		Csharp struct {
			RelOut string `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
		} `json:"csharp,omitempty" yaml:"csharp,omitempty"`
		Go struct {
			RelOut             string            `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
			PluginType         string            `json:"plugin_type,omitempty" yaml:"plugin_type,omitempty"`
			ImportPath         string            `json:"import_path,omitempty" yaml:"import_path,omitempty"`
			NoDefaultModifiers bool              `json:"no_default_modifiers,omitempty" yaml:"no_default_modifiers,omitempty"`
			Modifiers          map[string]string `json:"modifiers,omitempty" yaml:"modifiers,omitempty"`
		} `json:"go,omitempty" yaml:"go,omitempty"`
		Gogo struct {
			RelOut             string            `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
			PluginType         string            `json:"plugin_type,omitempty" yaml:"plugin_type,omitempty"`
			ImportPath         string            `json:"import_path,omitempty" yaml:"import_path,omitempty"`
			NoDefaultModifiers bool              `json:"no_default_modifiers,omitempty" yaml:"no_default_modifiers,omitempty"`
			Modifiers          map[string]string `json:"modifiers,omitempty" yaml:"modifiers,omitempty"`
		} `json:"gogo,omitempty" yaml:"gogo,omitempty"`
		Objc struct {
			RelOut string `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
		} `json:"objc,omitempty" yaml:"objc,omitempty"`
		Python struct {
			RelOut string `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
		} `json:"python,omitempty" yaml:"python,omitempty"`
		Ruby struct {
			RelOut string `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
		} `json:"ruby,omitempty" yaml:"ruby,omitempty"`
		DescriptorSet struct {
			RelOut         string `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
			FileName       string `json:"file_name,omitempty" yaml:"file_name,omitempty"`
			IncludeImports bool   `json:"include_imports,omitempty" yaml:"include_imports,omitempty"`
		} `json:"descriptor_set,omitempty" yaml:"descriptor_set,omitempty"`
		Letmegrpc struct {
			RelOut             string            `json:"rel_out,omitempty" yaml:"rel_out,omitempty"`
			ImportPath         string            `json:"import_path,omitempty" yaml:"import_path,omitempty"`
			NoDefaultModifiers bool              `json:"no_default_modifiers,omitempty" yaml:"no_default_modifiers,omitempty"`
			Modifiers          map[string]string `json:"modifiers,omitempty" yaml:"modifiers,omitempty"`
		} `json:"letmegrpc,omitempty" yaml:"letmegrpc,omitempty"`
	} `json:"options,omitempty" yaml:"options,omitempty"`
}

// ParseFileCompileOptions parses a FileCompileOptions struct from the filePath.
//
// If file extension is .json, JSON parsing is attempted.
// If file extension is .yml or .yaml, YAML parsing is attemped.
// Otherwise, YAML parsing is first attempted, then JSON parsing.
func ParseFileCompileOptions(filePath string) (*FileCompileOptions, error) {
	return parseFileCompileOptions(filePath)
}

// ToCompileOptions converts a FileCompileOptions to a CompileOptions.
func (f *FileCompileOptions) ToCompileOptions() (*CompileOptions, error) {
	return toCompileOptions(f)
}

// Compiler compiles protocol buffer files.
type Compiler interface {
	// Compile compiles the protocol buffer files in dirPath and outputs the generated
	// files to outDirPath, using the given CompileOptions.
	Compile(dirPath string, outDirPath string, compileOptions *CompileOptions) ([]*Command, error)
}

// CompilerOptions are options for a Compiler.
type CompilerOptions struct{}

// NewServerCompiler returns a new server Compiler.
func NewServerCompiler(options CompilerOptions) Compiler {
	return newServerCompiler(options)
}

// APIServerOptions are options for an APIServer.
type APIServerOptions struct {
	NoLogging bool
}

// NewAPIServer returns a new APIServer for the given Compiler.
func NewAPIServer(compiler Compiler, options APIServerOptions) APIServer {
	return newAPIServer(compiler, options)
}

// NewLocalAPIClient returns a new APIClient that calls the APIServer directly.
func NewLocalAPIClient(apiServer APIServer) APIClient {
	return newLocalAPIClient(apiServer)
}

// NewClientCompiler returns a new client Compiler for the given APIClient.
func NewClientCompiler(apiClient APIClient, options CompilerOptions) Compiler {
	return newClientCompiler(apiClient, options)
}

// GoPluginTypeSimpleValueOf returns the GoPluginType for the simple value.
func GoPluginTypeSimpleValueOf(s string) (GoPluginType, error) {
	goPluginTypeObj, ok := GoPluginType_value[fmt.Sprintf("GO_PLUGIN_TYPE_%s", strings.ToUpper(s))]
	if !ok {
		return GoPluginType_GO_PLUGIN_TYPE_NONE, fmt.Errorf("no protoeasy.GoPluginType for %s", s)
	}
	return GoPluginType(goPluginTypeObj), nil
}

// SimpleString returns the simple value for the GoPluginType.
func (x GoPluginType) SimpleString() string {
	s, ok := GoPluginType_name[int32(x)]
	if !ok {
		return strconv.Itoa(int(x))
	}
	return strings.TrimPrefix(strings.ToLower(s), "go_plugin_type_")
}

// AllGoPluginTypeSimpleStrings returns the simple values for all GoPluginTypes.
func AllGoPluginTypeSimpleStrings() []string {
	simpleStrings := make([]string, len(GoPluginType_name)-1)
	for i := range GoPluginType_name {
		if i != 0 {
			simpleStrings[i-1] = ((GoPluginType)(i)).SimpleString()
		}
	}
	return simpleStrings
}

// GogoPluginTypeSimpleValueOf returns the GogoPluginType for the simple value.
func GogoPluginTypeSimpleValueOf(s string) (GogoPluginType, error) {
	gogoPluginTypeObj, ok := GogoPluginType_value[fmt.Sprintf("GOGO_PLUGIN_TYPE_%s", strings.ToUpper(s))]
	if !ok {
		return GogoPluginType_GOGO_PLUGIN_TYPE_NONE, fmt.Errorf("no protoeasy.GogoPluginType for %s", s)
	}
	return GogoPluginType(gogoPluginTypeObj), nil
}

// SimpleString returns the simple value for the GogoPluginType.
func (x GogoPluginType) SimpleString() string {
	s, ok := GogoPluginType_name[int32(x)]
	if !ok {
		return strconv.Itoa(int(x))
	}
	return strings.TrimPrefix(strings.ToLower(s), "gogo_plugin_type_")
}

// AllGogoPluginTypeSimpleStrings returns the simple values for all GogoPluginTypes.
func AllGogoPluginTypeSimpleStrings() []string {
	simpleStrings := make([]string, len(GogoPluginType_name)-1)
	for i := range GogoPluginType_name {
		if i != 0 {
			simpleStrings[i-1] = ((GogoPluginType)(i)).SimpleString()
		}
	}
	return simpleStrings
}
