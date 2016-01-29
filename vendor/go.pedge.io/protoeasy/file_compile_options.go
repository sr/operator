package protoeasy

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v2"
)

func parseFileCompileOptions(filePath string) (_ *FileCompileOptions, retErr error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer func() {
		if err := file.Close(); err != nil && retErr == nil {
			retErr = err
		}
	}()
	data, err := ioutil.ReadAll(file)
	if err != nil {
		return nil, err
	}
	switch strings.ToLower(filepath.Ext(filePath)) {
	case "json":
		return parseFileCompileOptionsJSON(data)
	case "yml", "yaml":
		return parseFileCompileOptionsYAML(data)
	default:
		fileCompileOptionsYAML, yamlErr := parseFileCompileOptionsYAML(data)
		if yamlErr != nil {
			fileCompileOptionsJSON, jsonErr := parseFileCompileOptionsJSON(data)
			if jsonErr != nil {
				return nil, fmt.Errorf("protoeasy: could not parse protoeasy options file in either YAML or JSON: %v %v", yamlErr, jsonErr)
			}
			return fileCompileOptionsJSON, nil
		}
		return fileCompileOptionsYAML, nil
	}
}

func parseFileCompileOptionsJSON(data []byte) (*FileCompileOptions, error) {
	fileCompileOptions := &FileCompileOptions{}
	if err := json.Unmarshal(data, fileCompileOptions); err != nil {
		return nil, err
	}
	return fileCompileOptions, nil
}

func parseFileCompileOptionsYAML(data []byte) (*FileCompileOptions, error) {
	fileCompileOptions := &FileCompileOptions{}
	if err := yaml.Unmarshal(data, fileCompileOptions); err != nil {
		return nil, err
	}
	return fileCompileOptions, nil
}

func toCompileOptions(from *FileCompileOptions) (*CompileOptions, error) {
	if from.Version == "" {
		return nil, fmt.Errorf("protoeasy: must set version for protoeasy options file, valid versions are %s", strings.Join(getValidVersions(), ","))
	}
	switch strings.ToLower(from.Version) {
	case "v1":
		return toCompileOptionsV1(from)
	default:
		return nil, fmt.Errorf("protoeasy: invalid version for protoeasy options file, valid versions are %s", strings.Join(getValidVersions(), ","))
	}
}

func toCompileOptionsV1(from *FileCompileOptions) (*CompileOptions, error) {
	if from == nil {
		return nil, nil
	}
	to := &CompileOptions{}
	for _, plugin := range from.Plugins {
		switch strings.ToLower(plugin) {
		case "grpc":
			to.Grpc = true
		case "grpc_gateway":
			to.GrpcGateway = true
		case "cpp":
			to.Cpp = true
		case "csharp":
			to.Csharp = true
		case "go":
			to.Go = true
		case "gogo":
			to.Gogo = true
		case "objc":
			to.Objc = true
		case "python":
			to.Python = true
		case "ruby":
			to.Ruby = true
		case "descriptor_set":
			to.DescriptorSet = true
		default:
			return nil, fmt.Errorf("protoeasy: unknown plugin: %s", plugin)
		}
	}
	if from.Options.Go.PluginType != "" {
		switch strings.ToLower(from.Options.Go.PluginType) {
		case "go":
			to.GoPluginType = GoPluginType_GO_PLUGIN_TYPE_GO
		case "gofast":
			to.GoPluginType = GoPluginType_GO_PLUGIN_TYPE_GOFAST
		default:
			return nil, fmt.Errorf("protoeasy: unknwn go plugin type: %s", from.Options.Go.PluginType)
		}

	}
	if from.Options.Gogo.PluginType != "" {
		switch strings.ToLower(from.Options.Gogo.PluginType) {
		case "gogo":
			to.GogoPluginType = GogoPluginType_GOGO_PLUGIN_TYPE_GOGO
		case "gogofast":
			to.GogoPluginType = GogoPluginType_GOGO_PLUGIN_TYPE_GOGOFAST
		case "gogofaster":
			to.GogoPluginType = GogoPluginType_GOGO_PLUGIN_TYPE_GOGOFASTER
		case "gogoslick":
			to.GogoPluginType = GogoPluginType_GOGO_PLUGIN_TYPE_GOGOSLICK
		default:
			return nil, fmt.Errorf("protoeasy: unknwn gogo plugin type: %s", from.Options.Gogo.PluginType)
		}
	}
	to.NoDefaultIncludes = from.Options.NoDefaultIncludes
	to.ExcludePattern = from.Options.Exclude
	to.RelContext = from.Options.RelContext
	to.CppRelOut = from.Options.Cpp.RelOut
	to.CsharpRelOut = from.Options.Csharp.RelOut
	to.GoRelOut = from.Options.Go.RelOut
	to.GoImportPath = from.Options.Go.ImportPath
	to.GoNoDefaultModifiers = from.Options.Go.NoDefaultModifiers
	to.GoModifiers = from.Options.Go.Modifiers
	to.GogoRelOut = from.Options.Gogo.RelOut
	to.GogoImportPath = from.Options.Gogo.ImportPath
	to.GogoNoDefaultModifiers = from.Options.Gogo.NoDefaultModifiers
	to.GogoModifiers = from.Options.Gogo.Modifiers
	to.ObjcRelOut = from.Options.Objc.RelOut
	to.PythonRelOut = from.Options.Python.RelOut
	to.RubyRelOut = from.Options.Ruby.RelOut
	to.DescriptorSetRelOut = from.Options.DescriptorSet.RelOut
	to.DescriptorSetFileName = from.Options.DescriptorSet.FileName
	to.DescriptorSetIncludeImports = from.Options.DescriptorSet.IncludeImports
	// TODO(pedge): this should not be in this function
	// TODO(pedge): duplicated logic in goPlugin struct
	if to.NoDefaultIncludes {
		to.GoNoDefaultModifiers = true
		to.GogoNoDefaultModifiers = true
	}
	return to, nil
}

func getValidVersions() []string {
	validVersions := make([]string, len(FileCompileOptionsVersionToCompileOptionsFunc))
	i := 0
	for version := range FileCompileOptionsVersionToCompileOptionsFunc {
		validVersions[i] = version
		i++
	}
	return validVersions
}
