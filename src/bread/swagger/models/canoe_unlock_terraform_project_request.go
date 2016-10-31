package models

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	strfmt "github.com/go-openapi/strfmt"

	"github.com/go-openapi/errors"
)

// CanoeUnlockTerraformProjectRequest canoe unlock terraform project request
// swagger:model canoeUnlockTerraformProjectRequest
type CanoeUnlockTerraformProjectRequest struct {

	// project
	Project string `json:"project,omitempty"`

	// user email
	UserEmail string `json:"user_email,omitempty"`
}

// Validate validates this canoe unlock terraform project request
func (m *CanoeUnlockTerraformProjectRequest) Validate(formats strfmt.Registry) error {
	var res []error

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}
