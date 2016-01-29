package protoeasy

import (
	"bytes"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"

	"go.pedge.io/pkg/exec"
	"go.pedge.io/protolog"

	"github.com/docker/docker/pkg/archive"
)

const (
	tarCompression = archive.Gzip
)

// protoSpec specifies the absolute directory path being used as a base
// for the current compilation, as well as the relative (to DirPath)
// directory path to all protocol buffer files in each directory within DirPath.
type protoSpec struct {
	DirPath           string
	RelDirPathToFiles map[string][]string
}

func mkdir(dirPath string, subDirPaths ...string) error {
	if err := os.MkdirAll(dirPath, 0755); err != nil {
		return err
	}
	for _, subDirPath := range subDirPaths {
		if err := os.MkdirAll(filepath.Join(dirPath, subDirPath), 0755); err != nil {
			return err
		}
	}
	return nil
}

func getRelOutDirPaths(compileOptions *CompileOptions) []string {
	var relOutDirPaths []string
	for _, relOutDirPath := range []string{
		compileOptions.CppRelOut,
		compileOptions.CsharpRelOut,
		compileOptions.GoRelOut,
		compileOptions.GogoRelOut,
		compileOptions.ObjcRelOut,
		compileOptions.PythonRelOut,
		compileOptions.RubyRelOut,
	} {
		if relOutDirPath != "" {
			relOutDirPaths = append(relOutDirPaths, relOutDirPath)
		}
	}
	return relOutDirPaths
}

func getAllRelProtoFilePaths(dirPath string) ([]string, error) {
	var relProtoFilePaths []string
	if err := filepath.Walk(
		dirPath,
		func(filePath string, fileInfo os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if fileInfo.IsDir() {
				return nil
			}
			if filepath.Ext(filePath) != ".proto" {
				return nil
			}
			relFilePath, err := filepath.Rel(dirPath, filePath)
			if err != nil {
				return err
			}
			relProtoFilePaths = append(relProtoFilePaths, relFilePath)
			return nil
		},
	); err != nil {
		return nil, err
	}
	return relProtoFilePaths, nil
}

func getRelDirPathToFiles(relFilePaths []string) map[string][]string {
	relDirPathToFiles := make(map[string][]string)
	for _, relFilePath := range relFilePaths {
		relDirPath := filepath.Dir(relFilePath)
		if _, ok := relDirPathToFiles[relDirPath]; !ok {
			relDirPathToFiles[relDirPath] = make([]string, 0)
		}
		relDirPathToFiles[relDirPath] = append(relDirPathToFiles[relDirPath], filepath.Base(relFilePath))
	}
	return relDirPathToFiles
}

func filterFilePaths(filePaths []string, excludeFilePatterns []string) ([]string, error) {
	var filteredFilePaths []string
	for _, filePath := range filePaths {
		matched, err := filePathMatches(filePath, excludeFilePatterns)
		if err != nil {
			return nil, err
		}
		if !matched {
			filteredFilePaths = append(filteredFilePaths, filePath)
		}
	}
	return filteredFilePaths, nil
}

func filePathMatches(filePath string, excludeFilePatterns []string) (bool, error) {
	// TODO(pedge): handle this logic correctly
	for _, excludeFilePattern := range excludeFilePatterns {
		if strings.HasPrefix(filePath, excludeFilePattern) {
			return true, nil
		}
		matched, err := filepath.Match(excludeFilePattern, filePath)
		if err != nil {
			return false, err
		}
		if matched {
			return true, nil
		}
	}
	return false, nil
}

func tar(dirPath string, includeFiles []string) (retVal []byte, retErr error) {
	readCloser, err := archive.TarWithOptions(
		dirPath,
		&archive.TarOptions{
			IncludeFiles: includeFiles,
			Compression:  tarCompression,
			NoLchown:     true,
		},
	)
	if err != nil {
		return nil, err
	}
	defer func() {
		if err := readCloser.Close(); err != nil && retErr == nil {
			retErr = err
		}
	}()
	return ioutil.ReadAll(readCloser)
}

func untar(value []byte, dirPath string) error {
	return archive.Untar(
		bytes.NewReader(value),
		dirPath,
		&archive.TarOptions{
			Compression: tarCompression,
			NoLchown:    true,
		},
	)
}

func getGoPath() (string, error) {
	goPath := os.Getenv("GOPATH")
	if goPath == "" {
		return "", errGoPathNotSet
	}
	split := strings.Split(goPath, ":")
	if len(split) > 1 {
		protolog.Warnf("protoeasy: GOPATH %s has multiple directories, using first directory %s", goPath, split[0])
		return split[0], nil
	}
	return goPath, nil
}

func which(executable string) (string, error) {
	output, err := pkgexec.RunOutput("which", executable)
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(output)), nil
}

func mergeStringStringMaps(maps ...map[string]string) map[string]string {
	newMap := make(map[string]string)
	for _, m := range maps {
		for key, value := range m {
			newMap[key] = value
		}
	}
	return newMap
}

func copyStringStringMap(m map[string]string) map[string]string {
	return mergeStringStringMaps(m)
}
