package protoeasy

import "golang.org/x/net/context"

type clientCompiler struct {
	apiClient APIClient
	options   CompilerOptions
}

func newClientCompiler(apiClient APIClient, options CompilerOptions) *clientCompiler {
	return &clientCompiler{apiClient, options}
}

func (c *clientCompiler) Compile(dirPath string, outDirPath string, compileOptions *CompileOptions) (retVal []*Command, retErr error) {
	relFilePaths, err := getAllRelProtoFilePaths(dirPath)
	if err != nil {
		return nil, err
	}
	tar, err := tar(dirPath, relFilePaths)
	if err != nil {
		return nil, err
	}
	compileResponse, err := c.apiClient.Compile(
		context.Background(),
		&CompileRequest{
			Tar:            tar,
			CompileOptions: compileOptions,
		},
	)
	if err != nil {
		return nil, err
	}
	if err := untar(compileResponse.Tar, outDirPath); err != nil {
		return nil, err
	}
	if compileResponse.CompileInfo != nil {
		return compileResponse.CompileInfo.Command, nil
	}
	return nil, nil
}
