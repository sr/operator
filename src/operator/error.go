import (
	"fmt"

	"github.com/acsellers/inflections"
	"github.com/serenize/snaker"
)

type argumentRequiredError struct {
	argument string
}

func (a *argumentRequiredError) Error() string {
	return fmt.Errorf(
		"required argument is missing: %s",
		inflections.Dasherize(snaker.CamelToSnake(s)),
	)
}
