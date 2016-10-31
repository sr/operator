package models

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	strfmt "github.com/go-openapi/strfmt"

	"github.com/go-openapi/errors"
)

// CanoeTerraformResponse canoe terraform response
// swagger:model canoeTerraformResponse
type CanoeTerraformResponse struct {

	// deploy id
	DeployID int64 `json:"deploy_id,omitempty"`

	// error
	Error bool `json:"error,omitempty"`

	// message
	Message string `json:"message,omitempty"`

	// request id
	RequestID string `json:"request_id,omitempty"`
}

// Validate validates this canoe terraform response
func (m *CanoeTerraformResponse) Validate(formats strfmt.Registry) error {
	var res []error

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}
