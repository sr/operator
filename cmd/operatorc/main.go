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
	hubotOutDir  string
	serverOutDir string

	errNoSourceDir = errors.New("Please specify a input source directory.")
	errNoOutDir    = errors.New("Please specify at least one of --cmd-out, --hubot-out, or --server-out.")
)

func run() error {
	flag.StringVar(&cmdOutDir, "cmd-out", "", "The `directory` where to output command-line Go code.")
	flag.StringVar(&hubotOutDir, "hubot-out", "", "The `directory` where to output Hubot scripts.")
	flag.StringVar(&serverOutDir, "server-out", "", "The `directory` where to output operator server Go code.")
	flag.Parse()
	if flag.NArg() != 1 {
		return errNoSourceDir
	}
	inputDirPath := flag.Args()[0]
	outDirPath := inputDirPath
	options := &protoeasy.CompileOptions{
		Go:          true,
		Grpc:        true,
		GoModifiers: map[string]string{"operator.proto": "github.com/sr/operator"},
		// TODO(sr) Deal with hubot/proto. Perhaps write it out ourselves?
		//ExcludePattern: []string{"hubot/node_modules", "hubot/proto"},
		// TODO(sr) Will need to include operator.proto in this
		NoDefaultIncludes: true,
	}
	if cmdOutDir == "" && hubotOutDir == "" && serverOutDir == "" {
		return errNoOutDir
	}
	if cmdOutDir != "" {
		options.OperatorCmd = true
		options.OperatorCmdOut = cmdOutDir
	}
	if hubotOutDir != "" {
		options.OperatorHubot = true
		options.OperatorHubotOut = hubotOutDir
	}
	if serverOutDir != "" {
		options.OperatorServer = true
		options.OperatorServerOut = serverOutDir
	}
	compiler := protoeasy.DefaultClientCompiler
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
