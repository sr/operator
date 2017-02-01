package jib

import (
	"bytes"
	"html/template"
)

func renderTemplate(t *template.Template, context interface{}) (string, error) {
	buf := new(bytes.Buffer)

	err := t.Execute(buf, context)
	if err != nil {
		return "", err
	}
	return buf.String(), nil
}
