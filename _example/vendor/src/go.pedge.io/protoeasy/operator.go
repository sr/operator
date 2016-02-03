package protoeasy

import "fmt"

const protoPath = "/home/sr/src/github.com/sr/operator/_example/vendor/src/github.com/sr/operator/proto"

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
	flags = append(flags, fmt.Sprintf("-I%s", protoPath))
	return flags, nil
}
