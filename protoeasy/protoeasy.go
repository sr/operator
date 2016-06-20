/*
Package protoeasy is intended to make using protoc simpler.

Protoeasy compiles all protocol buffer files in a directory/subdirectories,
taking care of all include directories, takes care of gRPC compilation,
and take care of package import modifiers for Golang.
*/
package protoeasy

import (
	"strconv"
	"strings"
)

var (
	DefaultCompiler = NewCompiler(CompilerOptions{})
	// DefaultDescriptorSetFileName is the default descriptor set file name.
	DefaultDescriptorSetFileName = "descriptor-set.pb"
)

// Compiler compiles protocol buffer files.
type Compiler interface {
	// Compile compiles the protocol buffer files in dirPath and outputs the generated
	// files to outDirPath, using the given CompileOptions.
	Compile(dirPath string, outDirPath string, compileOptions *CompileOptions) ([]*Command, error)
}

// CompilerOptions are options for a Compiler.
type CompilerOptions struct{}

func NewCompiler(options CompilerOptions) Compiler {
	return newCompiler(options)
}

// SimpleString returns the simple value for the GoPluginType.
func (x GoPluginType) SimpleString() string {
	s, ok := GoPluginType_name[int32(x)]
	if !ok {
		return strconv.Itoa(int(x))
	}
	return strings.TrimPrefix(strings.ToLower(s), "go_plugin_type_")
}

// SimpleString returns the simple value for the GogoPluginType.
func (x GogoPluginType) SimpleString() string {
	s, ok := GogoPluginType_name[int32(x)]
	if !ok {
		return strconv.Itoa(int(x))
	}
	return strings.TrimPrefix(strings.ToLower(s), "gogo_plugin_type_")
}
