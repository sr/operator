package protoeasy

import (
	"fmt"
	"path/filepath"
	"sort"
	"strings"
)

// plugin is an individual flag provider for a specific language.
type plugin interface {
	// Flags gets the protoc flags for the plugin.
	Flags(protoSpec *protoSpec, relDirPath string, outDirPath string) ([]string, error)
}

func getPlugins(compileOptions *CompileOptions) []plugin {
	var plugins []plugin
	if compileOptions.Cpp {
		plugins = append(plugins, newCppPlugin(compileOptions))
	}
	if compileOptions.Csharp {
		plugins = append(plugins, newCsharpPlugin(compileOptions))
	}
	if compileOptions.Go {
		plugins = append(plugins, newGoPlugin(compileOptions))
	}
	if compileOptions.Gogo {
		plugins = append(plugins, newGogoPlugin(compileOptions))
	}
	if compileOptions.Objc {
		plugins = append(plugins, newObjcPlugin(compileOptions))
	}
	if compileOptions.Python {
		plugins = append(plugins, newPythonPlugin(compileOptions))
	}
	if compileOptions.Ruby {
		plugins = append(plugins, newRubyPlugin(compileOptions))
	}
	if compileOptions.DescriptorSet {
		plugins = append(plugins, newDescriptorSetPlugin(compileOptions))
	}
	if compileOptions.Letmegrpc {
		plugins = append(plugins, newLetmegrpcPlugin(compileOptions))
	}
	return plugins
}

func newCppPlugin(options *CompileOptions) plugin {
	return newGrpcPlugin("cpp", "cpp", options, options.CppRelOut)
}

func newCsharpPlugin(options *CompileOptions) plugin {
	return newGrpcPlugin("csharp", "csharp", options, options.CsharpRelOut)
}

func newGoPlugin(options *CompileOptions) plugin {
	if options == nil {
		options = &CompileOptions{}
	}
	return newBaseGoPlugin(
		options,
		options.GoRelOut,
		options.GoPluginType.SimpleString(),
		GoPluginType_GO_PLUGIN_TYPE_GO.SimpleString(),
		defaultGoModifierOptions,
		options.GoNoDefaultModifiers,
		options.GoModifiers,
		options.GoImportPath,
		"grpc-gateway",
		true,
	)
}

func newGogoPlugin(options *CompileOptions) plugin {
	if options == nil {
		options = &CompileOptions{}
	}
	return newBaseGoPlugin(
		options,
		options.GogoRelOut,
		options.GogoPluginType.SimpleString(),
		GogoPluginType_GOGO_PLUGIN_TYPE_GOGOFAST.SimpleString(),
		defaultGogoModifierOptions,
		options.GogoNoDefaultModifiers,
		options.GogoModifiers,
		options.GogoImportPath,
		"grpc-gateway",
		true,
	)
}

func newLetmegrpcPlugin(options *CompileOptions) plugin {
	if options == nil {
		options = &CompileOptions{}
	}
	return newBaseGoPlugin(
		options,
		options.LetmegrpcRelOut,
		"letmegrpc",
		"letmegrpc",
		defaultGogoModifierOptions,
		options.LetmegrpcNoDefaultModifiers,
		options.LetmegrpcModifiers,
		options.LetmegrpcImportPath,
		"",
		false,
	)
}

func newObjcPlugin(options *CompileOptions) plugin {
	return newGrpcPlugin("objc", "objective_c", options, options.ObjcRelOut)
}

func newPythonPlugin(options *CompileOptions) plugin {
	return newGrpcPlugin("python", "python", options, options.PythonRelOut)
}

func newRubyPlugin(options *CompileOptions) plugin {
	return newGrpcPlugin("ruby", "ruby", options, options.RubyRelOut)
}

type baseGoPlugin struct {
	options            *CompileOptions
	relOut             string
	pluginType         string
	defaultModifiers   map[string]string
	noDefaultModifiers bool
	modifiers          map[string]string
	importPath         string
	grpcGatewayPlugin  string
	hasGrpc            bool
}

func newBaseGoPlugin(
	options *CompileOptions,
	relOut string,
	pluginType string,
	defaultPluginType string,
	defaultModifiers map[string]string,
	noDefaultModifiers bool,
	modifiers map[string]string,
	importPath string,
	grpcGatewayPlugin string,
	hasGrpc bool,
) *baseGoPlugin {
	if options == nil {
		options = &CompileOptions{}
	}
	if pluginType == "none" {
		pluginType = defaultPluginType
	}
	if options.NoDefaultIncludes {
		noDefaultModifiers = true
	}
	return &baseGoPlugin{
		options,
		relOut,
		pluginType,
		defaultModifiers,
		noDefaultModifiers,
		modifiers,
		importPath,
		grpcGatewayPlugin,
		hasGrpc,
	}
}

func (p *baseGoPlugin) Flags(protoSpec *protoSpec, relDirPath string, outDirPath string) ([]string, error) {
	if p.relOut != "" {
		outDirPath = filepath.Join(outDirPath, p.relOut)
	}
	modifiers := p.getModifiers(protoSpec, relDirPath)
	goOutOpts := modifiers
	if p.hasGrpc && p.options.Grpc {
		goOutOpts = fmt.Sprintf("%s,plugins=grpc", goOutOpts)
	}
	var flags []string
	if len(goOutOpts) > 0 {
		flags = append(flags, fmt.Sprintf("--%s_out=%s:%s", p.pluginType, goOutOpts, outDirPath))
	} else {
		flags = append(flags, fmt.Sprintf("--%s_out=%s", p.pluginType, outDirPath))
	}
	if p.hasGrpc && p.grpcGatewayPlugin != "" && p.options.GrpcGateway {
		if len(modifiers) > 0 {
			flags = append(flags, fmt.Sprintf("--%s_out=%s:%s", p.grpcGatewayPlugin, modifiers, outDirPath))
		} else {
			flags = append(flags, fmt.Sprintf("--%s_out=%s", p.grpcGatewayPlugin, outDirPath))
		}
	}
	return flags, nil
}

func (p *baseGoPlugin) getModifiers(protoSpec *protoSpec, curRelDirPath string) string {
	var modifiers map[string]string
	if p.noDefaultModifiers {
		modifiers = make(map[string]string)
	} else {
		modifiers = copyStringStringMap(p.defaultModifiers)
	}
	for key, value := range p.modifiers {
		modifiers[key] = value
	}
	for relDirPath, files := range protoSpec.RelDirPathToFiles {
		if relDirPath != curRelDirPath {
			importPath := relDirPath
			if p.importPath != "" {
				importPath = filepath.Join(p.importPath, relDirPath)
			}
			// TODO(pedge)
			if importPath != "" && importPath != "." {
				for _, file := range files {
					modifiers[filepath.Join(relDirPath, file)] = importPath
				}
			}
		}
	}
	// this is just so the command line is easier to read and deterministic
	modifierKeys := make([]string, len(modifiers))
	i := 0
	for key := range modifiers {
		modifierKeys[i] = key
		i++
	}
	sort.Strings(modifierKeys)
	modifierStrings := make([]string, len(modifierKeys))
	for i, modifierKey := range modifierKeys {
		modifierStrings[i] = fmt.Sprintf("M%s=%s", modifierKey, modifiers[modifierKey])
	}
	return strings.Join(modifierStrings, ",")
}

type descriptorSetPlugin struct {
	options *CompileOptions
}

func newDescriptorSetPlugin(options *CompileOptions) *descriptorSetPlugin {
	if options == nil {
		options = &CompileOptions{}
	}
	return &descriptorSetPlugin{options}
}

func (p *descriptorSetPlugin) Flags(protoSpec *protoSpec, relDirPath string, outDirPath string) ([]string, error) {
	if p.options.DescriptorSetRelOut != "" {
		outDirPath = filepath.Join(outDirPath, p.options.DescriptorSetRelOut)
	}
	fileName := p.options.DescriptorSetFileName
	if fileName == "" {
		fileName = DefaultDescriptorSetFileName
	}
	args := []string{fmt.Sprintf("--descriptor_set_out=%s", filepath.Join(outDirPath, fileName))}
	if p.options.DescriptorSetIncludeImports {
		args = append(args, "--include_imports")
	}
	return args, nil
}

type basePlugin struct {
	name          string
	options       *CompileOptions
	relOutDirPath string
}

func newBasePlugin(name string, options *CompileOptions, relOutDirPath string) *basePlugin {
	if options == nil {
		options = &CompileOptions{}
	}
	return &basePlugin{name, options, relOutDirPath}
}

func (p *basePlugin) Flags(protoSpec *protoSpec, relDirPath string, outDirPath string) ([]string, error) {
	if p.relOutDirPath != "" {
		outDirPath = filepath.Join(outDirPath, p.relOutDirPath)
	}
	return []string{fmt.Sprintf("--%s_out=%s", p.name, outDirPath)}, nil
}

type grpcPlugin struct {
	*basePlugin
	grpcName string
}

func newGrpcPlugin(name string, grpcName string, options *CompileOptions, relOutDirPath string) *grpcPlugin {
	if options == nil {
		options = &CompileOptions{}
	}
	return &grpcPlugin{newBasePlugin(name, options, relOutDirPath), grpcName}
}

func (p *grpcPlugin) Flags(protoSpec *protoSpec, relDirPath string, outDirPath string) ([]string, error) {
	args, err := p.basePlugin.Flags(protoSpec, relDirPath, outDirPath)
	if err != nil {
		return nil, err
	}
	if p.options.Grpc {
		if p.relOutDirPath != "" {
			outDirPath = filepath.Join(outDirPath, p.relOutDirPath)
		}
		whichGrpcPlugin, err := which(fmt.Sprintf("grpc_%s_plugin", p.grpcName))
		if err != nil {
			return nil, err
		}
		return append(args, fmt.Sprintf("--grpc_out=%s", outDirPath), fmt.Sprintf("--plugin=protoc-gen-grpc=%s", whichGrpcPlugin)), nil
	}
	return args, nil
}
