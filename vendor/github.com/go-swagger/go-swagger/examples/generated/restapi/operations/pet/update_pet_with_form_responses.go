package pet

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"net/http"

	"github.com/go-openapi/runtime"
)

/*UpdatePetWithFormMethodNotAllowed Invalid input

swagger:response updatePetWithFormMethodNotAllowed
*/
type UpdatePetWithFormMethodNotAllowed struct {
}

// NewUpdatePetWithFormMethodNotAllowed creates UpdatePetWithFormMethodNotAllowed with default headers values
func NewUpdatePetWithFormMethodNotAllowed() *UpdatePetWithFormMethodNotAllowed {
	return &UpdatePetWithFormMethodNotAllowed{}
}

// WriteResponse to the client
func (o *UpdatePetWithFormMethodNotAllowed) WriteResponse(rw http.ResponseWriter, producer runtime.Producer) {

	rw.WriteHeader(405)
}
