package protoeasy

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"time"

	"go.pedge.io/proto/rpclog"
	"go.pedge.io/proto/time"

	"golang.org/x/net/context"
)

type apiServer struct {
	protorpclog.Logger
	compiler Compiler
	options  APIServerOptions
}

func newAPIServer(compiler Compiler, options APIServerOptions) *apiServer {
	return &apiServer{protorpclog.NewLogger("protoeasy.API"), compiler, options}
}

func (a *apiServer) Compile(ctx context.Context, request *CompileRequest) (response *CompileResponse, retErr error) {
	start := time.Now()
	if !a.options.NoLogging {
		defer func() { a.logCompile(request, response, retErr, start) }()
	}
	relContext := ""
	if request.CompileOptions != nil && request.CompileOptions.RelContext != "" {
		relContext = request.CompileOptions.RelContext
		if filepath.IsAbs(relContext) {
			return nil, fmt.Errorf("protoeasy: expected relative path, got %s", relContext)
		}
		// TODO(pedge)
		relOutDirPaths := getRelOutDirPaths(request.CompileOptions)
		if len(relOutDirPaths) != 0 {
			return nil, fmt.Errorf("protoeasy, context not supported with rel_out options, %v", relOutDirPaths)
		}
	}
	dirPath, err := ioutil.TempDir("", "protoeasy-input")
	if err != nil {
		return nil, err
	}
	defer func() {
		if err := os.RemoveAll(dirPath); err != nil && retErr == nil {
			retErr = err
		}
	}()
	outDirPath, err := ioutil.TempDir("", "protoeasy-output")
	if err != nil {
		return nil, err
	}
	defer func() {
		if err := os.RemoveAll(outDirPath); err != nil && retErr == nil {
			retErr = err
		}
	}()
	fullDirPath := dirPath
	fullOutDirPath := outDirPath
	if relContext != "" {
		fullDirPath = filepath.Join(dirPath, relContext)
		if err := os.MkdirAll(fullDirPath, 0755); err != nil {
			return nil, err
		}
		fullOutDirPath = filepath.Join(outDirPath, relContext)
		if err := os.MkdirAll(fullOutDirPath, 0755); err != nil {
			return nil, err
		}
	}
	if err := untar(request.Tar, fullDirPath); err != nil {
		return nil, err
	}
	commands, err := a.compiler.Compile(dirPath, outDirPath, request.CompileOptions)
	if err != nil {
		return nil, err
	}
	// TODO(pedge): this is what preventing rel_out options with context
	// we would need to move the output from each rel out outside of context
	tar, err := tar(fullOutDirPath, []string{"."})
	if err != nil {
		return nil, err
	}
	return &CompileResponse{
		Tar: tar,
		CompileInfo: &CompileInfo{
			Command:         commands,
			InputSizeBytes:  uint64(len(request.Tar)),
			OutputSizeBytes: uint64(len(tar)),
			Duration:        prototime.DurationToProto(time.Since(start)),
		},
	}, nil
}

func (a *apiServer) logCompile(request *CompileRequest, response *CompileResponse, err error, start time.Time) {
	var compileOptions *CompileOptions
	if request != nil {
		compileOptions = request.CompileOptions
	}
	var compileInfo *CompileInfo
	if response != nil {
		compileInfo = response.CompileInfo
	}
	a.Log(compileOptions, compileInfo, err, time.Since(start))
}
