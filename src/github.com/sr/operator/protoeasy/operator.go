package protoeasy

import (
	"fmt"
	"path/filepath"
)

const (
	OperatorPackage = "github.com/sr/operator"
	protocProgram   = "protoc"
)

type operatorPlugin struct {
	name         string
	outDir       string
	goImportPath string
}

func (p *operatorPlugin) Flags(
	protoSpec *protoSpec,
	relDirPath string,
	outDirPath string,
) ([]string, error) {
	return []string{
		fmt.Sprintf(
			"--operator%s_out=import_path=%s:%s",
			p.name,
			p.goImportPath,
			p.outDir,
		),
	}, nil
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
		args := []string{protocProgram, fmt.Sprintf("-I%s", dirPath)}
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
		plugins = append(plugins, &operatorPlugin{
			"ctl",
			options.OperatorCmdOut,
			options.GoImportPath,
		})
	}
	if options.OperatorLocal {
		plugins = append(plugins, &operatorPlugin{
			"local",
			options.OperatorLocalOut,
			options.GoImportPath,
		})
	}
	if options.OperatorServer {
		plugins = append(plugins, &operatorPlugin{
			"d",
			options.OperatorServerOut,
			options.GoImportPath,
		})
	}
	return plugins
}

func appendOperatorIncludes(goPath string, args []string) []string {
	return append(args, fmt.Sprintf("-I%s", filepath.Join(goPath, "src", OperatorPackage)))
}
