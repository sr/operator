package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"google.golang.org/grpc"

	"go.pedge.io/env"
	"go.pedge.io/pkg/cobra"
	"go.pedge.io/protoeasy"
	"go.pedge.io/protolog"

	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
)

type appEnv struct {
	Address string `env:"PROTOEASY_ADDRESS"`
}

type options struct {
	GoModifiers            []string
	GoPluginType           string
	GogoModifiers          []string
	GogoPluginType         string
	OutDirPath             string
	NoFileCompileOptions   bool
	FileCompileOptionsPath string
}

func main() {
	env.Main(do, &appEnv{})
}

func do(appEnvObj interface{}) error {
	appEnv := appEnvObj.(*appEnv)
	compileOptions := &protoeasy.CompileOptions{}
	options := &options{}

	rootCmd := &cobra.Command{
		Use: fmt.Sprintf("%s directory", os.Args[0]),
		Run: pkgcobra.RunBoundedArgs(pkgcobra.Bounds{Max: 1}, func(args []string) error {
			if err := optionsToCompileOptions(options, compileOptions); err != nil {
				return err
			}
			dirPath := ""
			if len(args) > 0 {
				dirPath = args[0]
			}
			if !options.NoFileCompileOptions {
				fileCompileOptionsPath := filepath.Join(dirPath, options.FileCompileOptionsPath)
				_, err := os.Stat(fileCompileOptionsPath)
				if err != nil {
					if !os.IsNotExist(err) {
						return err
					}
				} else {
					protolog.Infof("Using protoeasy options file at %s", fileCompileOptionsPath)
					fileCompileOptions, err := protoeasy.ParseFileCompileOptions(fileCompileOptionsPath)
					if err != nil {
						return err
					}
					// instead of doing a foundFileCompileOptionsFile bool
					if dirPath == "" {
						dirPath = "."
					}
					if fileCompileOptions.Dir != "" {
						dirPath = filepath.Join(dirPath, fileCompileOptions.Dir)
					}
					compileOptions, err = fileCompileOptions.ToCompileOptions()
					if err != nil {
						return err
					}
				}
			}
			if dirPath == "" {
				return fmt.Errorf("Directory path to base protoeasy compile must either be the first argument if no protoeasy options file found (usually %s)", protoeasy.DefaultFileCompileOptionsFile)
			}
			protolog.Infof("Using input directory %s", dirPath)
			outDirPath := dirPath
			if options.OutDirPath != "" {
				outDirPath = options.OutDirPath
			}
			protolog.Infof("Using output directory %s", outDirPath)
			data, err := json.Marshal(compileOptions)
			if err != nil {
				return err
			}
			protolog.Infof("Using compile options %s", string(data))
			pkgcobra.Check(run(appEnv, dirPath, outDirPath, compileOptions))
			return nil
		}),
	}
	bindCompileOptions(rootCmd.Flags(), compileOptions)
	bindOptions(rootCmd.Flags(), options)

	return rootCmd.Execute()
}

func bindCompileOptions(flagSet *pflag.FlagSet, compileOptions *protoeasy.CompileOptions) {
	flagSet.BoolVar(
		&compileOptions.Grpc,
		"grpc",
		false,
		"Output grpc files.",
	)
	flagSet.BoolVar(
		&compileOptions.GrpcGateway,
		"grpc-gateway",
		false,
		"Output grpc-gateway files.",
	)
	flagSet.BoolVar(
		&compileOptions.NoDefaultIncludes,
		"no-default-includes",
		false,
		"Do not import the default include directories, implies --go-no-default-modifiers,--gogo-no-default-modifiers.",
	)
	flagSet.StringSliceVar(
		&compileOptions.ExcludePattern,
		"exclude",
		[]string{},
		"Exclude file patterns.",
	)
	flagSet.StringVar(
		&compileOptions.RelContext,
		"context",
		"",
		"The directory we are within, must be relative. This directory will be the base of the include path.",
	)

	flagSet.BoolVar(
		&compileOptions.Cpp,
		"cpp",
		false,
		"Output cpp files.",
	)
	flagSet.StringVar(
		&compileOptions.CppRelOut,
		"cpp-rel-out",
		"",
		"The directory, relative to the output directory, to output cpp files.",
	)

	flagSet.BoolVar(
		&compileOptions.Csharp,
		"csharp",
		false,
		"Output csharp files.",
	)
	flagSet.StringVar(
		&compileOptions.CsharpRelOut,
		"csharp-rel-out",
		"",
		"The directory, relative to the output directory, to output csharp files.",
	)

	flagSet.BoolVar(
		&compileOptions.Go,
		"go",
		false,
		"Output go files.",
	)
	flagSet.StringVar(
		&compileOptions.GoRelOut,
		"go-rel-out",
		"",
		"The directory, relative to the output directory, to output go files.",
	)
	flagSet.StringVar(
		&compileOptions.GoImportPath,
		"go-import-path",
		"",
		"Go package.",
	)
	flagSet.BoolVar(
		&compileOptions.GoNoDefaultModifiers,
		"go-no-default-modifiers",
		false,
		"Do not set the default Mfile=package modifiers for --go_out.",
	)

	flagSet.BoolVar(
		&compileOptions.Gogo,
		"gogo",
		false,
		"Output gogo files.",
	)
	flagSet.StringVar(
		&compileOptions.GogoRelOut,
		"gogo-rel-out",
		"",
		"The directory, relative to the output directory, to output gogo files.",
	)
	flagSet.StringVar(
		&compileOptions.GogoImportPath,
		"gogo-import-path",
		"",
		"Gogo package.",
	)
	flagSet.BoolVar(
		&compileOptions.GogoNoDefaultModifiers,
		"gogo-no-default-modifiers",
		false,
		"Do not set the default Mfile=package modifiers for --gogo_out.",
	)

	flagSet.BoolVar(
		&compileOptions.Objc,
		"objc",
		false,
		"Output objc files.",
	)
	flagSet.StringVar(
		&compileOptions.ObjcRelOut,
		"objc-rel-out",
		"",
		"The directory, relative to the output directory, to output objc files.",
	)

	flagSet.BoolVar(
		&compileOptions.Python,
		"python",
		false,
		"Output python files.",
	)
	flagSet.StringVar(
		&compileOptions.PythonRelOut,
		"python-rel-out",
		"",
		"The directory, relative to the output directory, to output python files.",
	)

	flagSet.BoolVar(
		&compileOptions.Ruby,
		"ruby",
		false,
		"Output ruby files.",
	)
	flagSet.StringVar(
		&compileOptions.RubyRelOut,
		"ruby-rel-out",
		"",
		"The directory, relative to the output directory, to output ruby files.",
	)

	flagSet.BoolVar(
		&compileOptions.DescriptorSet,
		"descriptor-set",
		false,
		"Output descriptor set files.",
	)
	flagSet.StringVar(
		&compileOptions.DescriptorSetRelOut,
		"descriptor-set-rel-out",
		"",
		"The directory, relative to the output directory, to output descriptor set files.",
	)
	flagSet.StringVar(
		&compileOptions.DescriptorSetFileName,
		"descriptor-set-file-name",
		protoeasy.DefaultDescriptorSetFileName,
		"The file name of the outputted descriptor set.",
	)
	flagSet.BoolVar(
		&compileOptions.DescriptorSetIncludeImports,
		"descriptor-set-include-imports",
		false,
		"Pass --include_imports to protoc.",
	)
}

func bindOptions(flagSet *pflag.FlagSet, options *options) {
	flagSet.StringSliceVar(
		&options.GoModifiers,
		"go-modifier",
		[]string{},
		"Extra Mfile=package modifiers for --go_out, specify just as file=package to this flag.",
	)
	flagSet.StringVar(
		&options.GoPluginType,
		"go-plugin",
		"go",
		fmt.Sprintf("The go protoc plugin to use, allowed values are %s.", strings.Join(protoeasy.AllGoPluginTypeSimpleStrings(), ",")),
	)
	flagSet.StringSliceVar(
		&options.GogoModifiers,
		"gogo-modifier",
		[]string{},
		"Extra Mfile=package modifiers for --gogo_out, specify just as file=package to this flag.",
	)
	flagSet.StringVar(
		&options.GogoPluginType,
		"gogo-plugin",
		"gogofast",
		fmt.Sprintf("The gogo protoc plugin to use, allowed values are %s.", strings.Join(protoeasy.AllGogoPluginTypeSimpleStrings(), ",")),
	)
	flagSet.StringVar(
		&options.OutDirPath,
		"out",
		"",
		"Customize out directory path.",
	)
	flagSet.BoolVar(
		&options.NoFileCompileOptions,
		"no-file",
		false,
		fmt.Sprintf("Ignore any protoeasy options file (usually %s) and just use the flags for options", protoeasy.DefaultFileCompileOptionsFile),
	)
	flagSet.StringVarP(
		&options.FileCompileOptionsPath,
		"file",
		"f",
		protoeasy.DefaultFileCompileOptionsFile,
		`The file to check for to read protoeasy options from.
The path is relative to the input directory given as the first argument.
If file does not exist, just the flags will be used.
If the file exists, the file options will overwrite any passed flags unless --no-file is specified`,
	)
}

func optionsToCompileOptions(options *options, compileOptions *protoeasy.CompileOptions) error {
	if strings.ToLower(options.GoPluginType) == "none" {
		return fmt.Errorf("invalid value for --go-plugin: %s", options.GoPluginType)
	}
	goPluginType, err := protoeasy.GoPluginTypeSimpleValueOf(options.GoPluginType)
	if err != nil {
		return err
	}
	compileOptions.GoPluginType = goPluginType
	goModifiers, err := getModifiers(options.GoModifiers)
	if err != nil {
		return err
	}
	compileOptions.GoModifiers = goModifiers
	if strings.ToLower(options.GogoPluginType) == "none" {
		return fmt.Errorf("invalid value for --gogo-plugin: %s", options.GogoPluginType)
	}
	gogoPluginType, err := protoeasy.GogoPluginTypeSimpleValueOf(options.GogoPluginType)
	if err != nil {
		return err
	}
	compileOptions.GogoPluginType = gogoPluginType
	gogoModifiers, err := getModifiers(options.GogoModifiers)
	if err != nil {
		return err
	}
	compileOptions.GogoModifiers = gogoModifiers
	// TODO(pedge): this should not be in this function
	// TODO(pedge): duplicated logic in goPlugin struct
	if compileOptions.NoDefaultIncludes {
		compileOptions.GoNoDefaultModifiers = true
		compileOptions.GogoNoDefaultModifiers = true
	}
	return nil
}

func getModifiers(modifierStrings []string) (map[string]string, error) {
	modifiers := make(map[string]string)
	for _, modifierString := range modifierStrings {
		split := strings.SplitN(modifierString, "=", 2)
		if len(split) != 2 {
			return nil, fmt.Errorf("invalid go modifier value: %s", modifierString)
		}
		modifiers[split[0]] = split[1]
	}
	return modifiers, nil
}

func run(appEnv *appEnv, dirPath string, outDirPath string, compileOptions *protoeasy.CompileOptions) error {
	compiler := protoeasy.DefaultClientCompiler
	if appEnv.Address != "" {
		clientConn, err := grpc.Dial(appEnv.Address, grpc.WithInsecure())
		if err != nil {
			return err
		}
		compiler = protoeasy.NewClientCompiler(
			protoeasy.NewAPIClient(
				clientConn,
			),
			protoeasy.CompilerOptions{},
		)
	}

	commands, err := compiler.Compile(dirPath, outDirPath, compileOptions)
	if err != nil {
		return err
	}
	for _, command := range commands {
		if len(command.Arg) > 0 {
			protolog.Infof("\n%s\n", strings.Join(command.Arg, " \\\n\t"))
		}
	}
	return nil
}
