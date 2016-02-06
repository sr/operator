package protoeasy

import (
	"fmt"
	"path/filepath"
)

const (
	protocCmd     = "protoc"
	operatorProto = "github.com/sr/operator"
)

type operatorPlugin struct {
	name   string
	outDir string
}

func (p *operatorPlugin) Flags(
	protoSpec *protoSpec,
	relDirPath string,
	outDirPath string,
) ([]string, error) {
	return []string{fmt.Sprintf("--operator%s_out=%s", p.name, p.outDir)}, nil
}

func getOperatorCommands(
	dirPath string,
	outDirPath string,
	goPath string,
	protoSpec *protoSpec,
	options *CompileOptions,
) ([]*Command, error) {
	var commands []*Command
	for _, plugin := range getOperatorPlugins(options) {
		args := []string{protocCmd, fmt.Sprintf("-I%s", dirPath)}
		args = appendOperatorIncludes(goPath, args)
		flags, err := plugin.Flags(protoSpec, "", outDirPath)
		if err != nil {
			return nil, err
		}
		args = append(args, flags...)
		for relDirPath, files := range protoSpec.RelDirPathToFiles {
			for _, file := range files {
				args = append(args, filepath.Join(dirPath, relDirPath, file))
			}
		}
		commands = append(commands, &Command{Arg: args})
	}
	return commands, nil
}

func getOperatorPlugins(options *CompileOptions) []plugin {
	var plugins []plugin
	if options.OperatorCmd {
		plugins = append(plugins, &operatorPlugin{"cmd", options.OperatorCmdOut})
	}
	if options.OperatorHubot {
		plugins = append(plugins, &operatorPlugin{"hubot", options.OperatorHubotOut})
	}
	if options.OperatorServer {
		plugins = append(plugins, &operatorPlugin{"d", options.OperatorServerOut})
	}
	return plugins
}

func appendOperatorIncludes(goPath string, args []string) []string {
	return append(args, fmt.Sprintf("-I%s", filepath.Join(goPath, "src", operatorProto)))
}
