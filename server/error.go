package server

import (
	"fmt"

	"github.com/acsellers/inflections"
	"github.com/serenize/snaker"
)

type argumentRequiredError struct {
	argument string
}

func (a *argumentRequiredError) Error() string {
	return fmt.Sprintf(
		"required argument is missing: %s",
		inflections.Dasherize(snaker.CamelToSnake(a.argument)),
	)
}
