package generator

import (
	"strings"
	"text/template"

	"github.com/kr/text"
	"github.com/serenize/snaker"
)

const wrapLimit = 80

func NewTemplate(name string, content string) *template.Template {
	return template.Must(template.New(name).Funcs(template.FuncMap{
		"wrap":          text.Wrap,
		"wrappedIndent": wrappedIndent,
		"camelCase":     camelCase,
	}).Parse(content))
}

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
