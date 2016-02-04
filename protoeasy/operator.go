package protoeasy

import (
	"fmt"
	"path/filepath"
)

const operatorProto = "github.com/sr/operator/proto"

type operatorPlugin struct {
	name   string
	outDir string
}

func newOperatorHubotPlugin(options *CompileOptions) plugin {
	return &operatorPlugin{"hubot", options.OperatorHubotOut}
}

func (p *operatorPlugin) Flags(
	protoSpec *protoSpec,
	relDirPath string,
	outDirPath string,
) ([]string, error) {
	var flags []string
	flags = append(flags, fmt.Sprintf("--operator%s_out=%s", p.name, p.outDir))
	return flags, nil
}

func appendOperatorIncludes(goPath string, args []string) []string {
	return append(args, fmt.Sprintf("-I%s", filepath.Join(goPath, "src", operatorProto)))
}
