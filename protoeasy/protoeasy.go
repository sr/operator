/*
Package protoeasy is intended to make using protoc simpler.

Protoeasy compiles all protocol buffer files in a directory/subdirectories,
taking care of all include directories, takes care of gRPC compilation,
and take care of package import modifiers for Golang.
*/
package protoeasy

type CompileOptions struct {
	Grpc                        bool
	GrpcGateway                 bool
	NoDefaultIncludes           bool
	ExcludePattern              []string
	RelContext                  string
	Cpp                         bool
	CppRelOut                   string
	Csharp                      bool
	CsharpRelOut                string
	Go                          bool
	GoPluginType                GoPluginType
	GoRelOut                    string
	GoImportPath                string
	GoNoDefaultModifiers        bool
	GoModifiers                 map[string]string
	Gogo                        bool
	GogoPluginType              GogoPluginType
	GogoRelOut                  string
	GogoImportPath              string
	GogoNoDefaultModifiers      bool
	GogoModifiers               map[string]string
	Objc                        bool
	ObjcRelOut                  string
	Python                      bool
	PythonRelOut                string
	Ruby                        bool
	RubyRelOut                  string
	DescriptorSet               bool
	DescriptorSetRelOut         string
	DescriptorSetFileName       string
	DescriptorSetIncludeImports bool
	Letmegrpc                   bool
	LetmegrpcRelOut             string
	LetmegrpcImportPath         string
	LetmegrpcNoDefaultModifiers bool
	LetmegrpcModifiers          map[string]string
	OperatorCmd                 bool
	OperatorCmdOut              string
	OperatorHubot               bool
	OperatorHubotOut            string
	OperatorLocal               bool
	OperatorLocalOut            string
	OperatorServer              bool
	OperatorServerOut           string
}

type Command struct {
	Arg []string
}

// CompilerOptions are options for a Compiler.
type CompilerOptions struct{}

// Compiler compiles protocol buffer files.
type Compiler interface {
	// Compile compiles the protocol buffer files in dirPath and outputs the generated
	// files to outDirPath, using the given CompileOptions.
	Compile(dirPath string, outDirPath string, compileOptions *CompileOptions) ([]*Command, error)
}

func NewCompiler(options CompilerOptions) Compiler {
	return newCompiler(options)
}
