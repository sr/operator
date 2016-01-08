package generator

import (
	"strings"

	"github.com/acsellers/inflections"
	"github.com/kr/text"
	"github.com/serenize/snaker"
)

const wrapLimit = 80

func wrappedIndent(s string, indentS string) string {
	return wrap(text.Indent(s, indentS))
}

func wrap(s string) string {
	return text.Wrap(s, wrapLimit)
}

func camelCase(s string) string {
	// TODO handle more than ID
	return strings.Replace(snaker.SnakeToCamel(s), "ID", "Id", 1)
}

func dasherize(s string) string {
	return inflections.Dasherize(s)
}
