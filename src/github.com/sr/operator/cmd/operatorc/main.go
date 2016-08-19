package main

import (
	"errors"
	"flag"
	"fmt"
	"os"
	"strings"

	"github.com/sr/operator/protoeasy"
)

var (
	cmdOutDir    string
	localOutDir  string
	serverOutDir string
	importPath   string

	errNoSourceDir  = errors.New("Please specify a input source directory.")
	errNoOutDir     = errors.New("Please specify at least one of --cmd-out, --local-out, or --server-out.")
	errNoImportPath = errors.New("The `import-path` flag is required.")
)

func run() error {
	flag.StringVar(&cmdOutDir, "cmd-out", "", "The `directory` where to output the command-line Go code.")
	flag.StringVar(&localOutDir, "local-out", "", "The `directory` where to output TODO(sr).")
	flag.StringVar(&serverOutDir, "server-out", "", "The `directory` where to output operator server Go code.")
	flag.StringVar(&importPath, "import-path", "", "The base `import-path` under which service packages are defined.")
	flag.Parse()
	if flag.NArg() != 1 {
		return errNoSourceDir
	}
	if importPath == "" {
		return errNoImportPath
	}
	inputDirPath := flag.Args()[0]
	outDirPath := inputDirPath
	options := &protoeasy.CompileOptions{
		Go:           true,
		Grpc:         true,
		GoImportPath: importPath,
		GoModifiers:  map[string]string{"operator.proto": protoeasy.OperatorPackage},
		// TODO(sr) Will need to include operator.proto in this
		NoDefaultIncludes: true,
	}
	if cmdOutDir == "" && localOutDir == "" && serverOutDir == "" {
		return errNoOutDir
	}
	if cmdOutDir != "" {
		options.OperatorCmd = true
		options.OperatorCmdOut = cmdOutDir
	}
	if localOutDir != "" {
		options.OperatorLocal = true
		options.OperatorLocalOut = localOutDir
	}
	if serverOutDir != "" {
		options.OperatorServer = true
		options.OperatorServerOut = serverOutDir
	}
	compiler := protoeasy.NewCompiler(protoeasy.CompilerOptions{})
	commands, err := compiler.Compile(inputDirPath, outDirPath, options)
	if err != nil {
		return err
	}
	if _, ok := os.LookupEnv("OPERATORC_DEBUG"); ok {
		for _, command := range commands {
			if len(command.Arg) > 0 {
				fmt.Printf("\n%s\n", strings.Join(command.Arg, " \\\n\t"))
			}
		}
	}
	return nil
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "operatorc: %v\n", err)
		os.Exit(1)
	}
}
