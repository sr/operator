package protoeasy

import (
	"strconv"
	"strings"
)

type GoPluginType int32

const (
	GoPluginType_GO_PLUGIN_TYPE_NONE   GoPluginType = 0
	GoPluginType_GO_PLUGIN_TYPE_GO     GoPluginType = 1
	GoPluginType_GO_PLUGIN_TYPE_GOFAST GoPluginType = 2
)

var goPluginType_name = map[int32]string{
	0: "GO_PLUGIN_TYPE_NONE",
	1: "GO_PLUGIN_TYPE_GO",
	2: "GO_PLUGIN_TYPE_GOFAST",
}

func (x GoPluginType) String() string {
	s, ok := goPluginType_name[int32(x)]
	if ok {
		return s
	}
	return strconv.Itoa(int(x))
}

func (x GoPluginType) SimpleString() string {
	s, ok := goPluginType_name[int32(x)]
	if !ok {
		return strconv.Itoa(int(x))
	}
	return strings.TrimPrefix(strings.ToLower(s), "go_plugin_type_")
}

type GogoPluginType int32

const (
	GogoPluginType_GOGO_PLUGIN_TYPE_NONE       GogoPluginType = 0
	GogoPluginType_GOGO_PLUGIN_TYPE_GOGO       GogoPluginType = 1
	GogoPluginType_GOGO_PLUGIN_TYPE_GOGOFAST   GogoPluginType = 2
	GogoPluginType_GOGO_PLUGIN_TYPE_GOGOFASTER GogoPluginType = 3
	GogoPluginType_GOGO_PLUGIN_TYPE_GOGOSLICK  GogoPluginType = 4
)

var gogoPluginType_name = map[int32]string{
	0: "GOGO_PLUGIN_TYPE_NONE",
	1: "GOGO_PLUGIN_TYPE_GOGO",
	2: "GOGO_PLUGIN_TYPE_GOGOFAST",
	3: "GOGO_PLUGIN_TYPE_GOGOFASTER",
	4: "GOGO_PLUGIN_TYPE_GOGOSLICK",
}

func (x GogoPluginType) SimpleString() string {
	s, ok := gogoPluginType_name[int32(x)]
	if ok {
		return s
	}
	return strconv.Itoa(int(x))
}
