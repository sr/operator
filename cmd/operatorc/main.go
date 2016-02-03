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
	hubotOutDir string
)

func run() error {
	flag.StringVar(&hubotOutDir, "hubot-out", "", "The `directory` where to output generated Hubot scripts.")
	flag.Parse()
	fmt.Printf("%v", flag.Args())
	if len(flag.Args()) != 1 {
		return errors.New("Please specify a input source directory.")
	}
	inputDirPath := flag.Args()[0]
	outDirPath := inputDirPath
	options := &protoeasy.CompileOptions{
		// TODO(sr) Deal with hubot/proto. Perhaps write out ourselves??
		ExcludePattern: []string{"hubot/node_modules", "hubot/proto"},
		// TODO(sr) Will need to include operator.proto in this
		NoDefaultIncludes: false,
	}
	if hubotOutDir != "" {
		options.OperatorHubot = true
		options.OperatorHubotOut = hubotOutDir
	}
	// TODO(sr) bail if none of hubot, cmd, or server are set
	compiler := protoeasy.DefaultClientCompiler
	commands, err := compiler.Compile(inputDirPath, outDirPath, options)
	if err != nil {
		return err
	}
	for _, command := range commands {
		if len(command.Arg) > 0 {
			fmt.Printf("\n%s\n", strings.Join(command.Arg, " \\\n\t"))
		}
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

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "operatorc: %v", err)
		os.Exit(1)
	}
}
