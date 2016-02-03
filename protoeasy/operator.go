package protoeasy

import "fmt"

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
