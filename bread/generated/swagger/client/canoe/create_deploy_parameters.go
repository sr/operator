package canoe

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/runtime"
	cr "github.com/go-openapi/runtime/client"

	strfmt "github.com/go-openapi/strfmt"

	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/swagger/models"
)

// NewCreateDeployParams creates a new CreateDeployParams object
// with the default values initialized.
func NewCreateDeployParams() *CreateDeployParams {
	var ()
	return &CreateDeployParams{

		timeout: cr.DefaultTimeout,
	}
}

// NewCreateDeployParamsWithTimeout creates a new CreateDeployParams object
// with the default values initialized, and the ability to set a timeout on a request
func NewCreateDeployParamsWithTimeout(timeout time.Duration) *CreateDeployParams {
	var ()
	return &CreateDeployParams{

		timeout: timeout,
	}
}

// NewCreateDeployParamsWithContext creates a new CreateDeployParams object
// with the default values initialized, and the ability to set a context for a request
func NewCreateDeployParamsWithContext(ctx context.Context) *CreateDeployParams {
	var ()
	return &CreateDeployParams{

		Context: ctx,
	}
}

// NewCreateDeployParamsWithHTTPClient creates a new CreateDeployParams object
// with the default values initialized, and the ability to set a custom HTTPClient for a request
func NewCreateDeployParamsWithHTTPClient(client *http.Client) *CreateDeployParams {
	var ()
	return &CreateDeployParams{
		HTTPClient: client,
	}
}

/*CreateDeployParams contains all the parameters to send to the API endpoint
for the create deploy operation typically these are written to a http.Request
*/
type CreateDeployParams struct {

	/*Body*/
	Body *models.BreadCreateDeployRequest

	timeout    time.Duration
	Context    context.Context
	HTTPClient *http.Client
}

// WithTimeout adds the timeout to the create deploy params
func (o *CreateDeployParams) WithTimeout(timeout time.Duration) *CreateDeployParams {
	o.SetTimeout(timeout)
	return o
}

// SetTimeout adds the timeout to the create deploy params
func (o *CreateDeployParams) SetTimeout(timeout time.Duration) {
	o.timeout = timeout
}

// WithContext adds the context to the create deploy params
func (o *CreateDeployParams) WithContext(ctx context.Context) *CreateDeployParams {
	o.SetContext(ctx)
	return o
}

// SetContext adds the context to the create deploy params
func (o *CreateDeployParams) SetContext(ctx context.Context) {
	o.Context = ctx
}

// WithHTTPClient adds the HTTPClient to the create deploy params
func (o *CreateDeployParams) WithHTTPClient(client *http.Client) *CreateDeployParams {
	o.SetHTTPClient(client)
	return o
}

// SetHTTPClient adds the HTTPClient to the create deploy params
func (o *CreateDeployParams) SetHTTPClient(client *http.Client) {
	o.HTTPClient = client
}

// WithBody adds the body to the create deploy params
func (o *CreateDeployParams) WithBody(body *models.BreadCreateDeployRequest) *CreateDeployParams {
	o.SetBody(body)
	return o
}

// SetBody adds the body to the create deploy params
func (o *CreateDeployParams) SetBody(body *models.BreadCreateDeployRequest) {
	o.Body = body
}

// WriteToRequest writes these params to a swagger request
func (o *CreateDeployParams) WriteToRequest(r runtime.ClientRequest, reg strfmt.Registry) error {

	r.SetTimeout(o.timeout)
	var res []error

	if o.Body == nil {
		o.Body = new(models.BreadCreateDeployRequest)
	}

	if err := r.SetBodyParam(o.Body); err != nil {
		return err
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}