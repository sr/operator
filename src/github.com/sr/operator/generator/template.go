package generator

import (
	"strings"
	"text/template"
	"unicode"
	"unicode/utf8"

	"github.com/acsellers/inflections"
	"github.com/kr/text"
	"github.com/serenize/snaker"
)

const wrapLimit = 80

var funcMap = template.FuncMap{
	"camelCase":     camelCase,
	"dasherize":     dasherize,
	"lowerCase":     lowerCase,
	"oneLine":       oneLine,
	"wrap":          wrap,
	"wrappedIndent": wrappedIndent,
}

func camelCase(s string) string {
	// TODO(sr) The horror
	return strings.Replace(strings.Replace(snaker.SnakeToCamel(s), "ID", "Id", 1), "API", "Api", 1)
}

func dasherize(s string) string {
	return inflections.Dasherize(snaker.CamelToSnake(s))
}

func lowerCase(s string) string {
	r, n := utf8.DecodeRuneInString(s)
	return string(unicode.ToLower(r)) + s[n:]
}

func oneLine(s string) string {
	return strings.Replace(s, "\n", " ", -1)
}

func wrappedIndent(s string, indentS string) string {
	return text.Indent(text.Wrap(s, wrapLimit-len(indentS)), indentS)
}

func wrap(s string) string {
	return text.Wrap(s, wrapLimit)
}
