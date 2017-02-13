package tasks

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/runtime"
	cr "github.com/go-openapi/runtime/client"
	"github.com/go-openapi/swag"

	strfmt "github.com/go-openapi/strfmt"
)

// NewAddCommentToTaskParams creates a new AddCommentToTaskParams object
// with the default values initialized.
func NewAddCommentToTaskParams() *AddCommentToTaskParams {
	var ()
	return &AddCommentToTaskParams{

		timeout: cr.DefaultTimeout,
	}
}

// NewAddCommentToTaskParamsWithTimeout creates a new AddCommentToTaskParams object
// with the default values initialized, and the ability to set a timeout on a request
func NewAddCommentToTaskParamsWithTimeout(timeout time.Duration) *AddCommentToTaskParams {
	var ()
	return &AddCommentToTaskParams{

		timeout: timeout,
	}
}

// NewAddCommentToTaskParamsWithContext creates a new AddCommentToTaskParams object
// with the default values initialized, and the ability to set a context for a request
func NewAddCommentToTaskParamsWithContext(ctx context.Context) *AddCommentToTaskParams {
	var ()
	return &AddCommentToTaskParams{

		Context: ctx,
	}
}

// NewAddCommentToTaskParamsWithHTTPClient creates a new AddCommentToTaskParams object
// with the default values initialized, and the ability to set a custom HTTPClient for a request
func NewAddCommentToTaskParamsWithHTTPClient(client *http.Client) *AddCommentToTaskParams {
	var ()
	return &AddCommentToTaskParams{
		HTTPClient: client,
	}
}

/*AddCommentToTaskParams contains all the parameters to send to the API endpoint
for the add comment to task operation typically these are written to a http.Request
*/
type AddCommentToTaskParams struct {

	/*Body
	  The comment to add

	*/
	Body AddCommentToTaskBody
	/*ID
	  The id of the item

	*/
	ID int64

	timeout    time.Duration
	Context    context.Context
	HTTPClient *http.Client
}

// WithTimeout adds the timeout to the add comment to task params
func (o *AddCommentToTaskParams) WithTimeout(timeout time.Duration) *AddCommentToTaskParams {
	o.SetTimeout(timeout)
	return o
}

// SetTimeout adds the timeout to the add comment to task params
func (o *AddCommentToTaskParams) SetTimeout(timeout time.Duration) {
	o.timeout = timeout
}

// WithContext adds the context to the add comment to task params
func (o *AddCommentToTaskParams) WithContext(ctx context.Context) *AddCommentToTaskParams {
	o.SetContext(ctx)
	return o
}

// SetContext adds the context to the add comment to task params
func (o *AddCommentToTaskParams) SetContext(ctx context.Context) {
	o.Context = ctx
}

// WithHTTPClient adds the HTTPClient to the add comment to task params
func (o *AddCommentToTaskParams) WithHTTPClient(client *http.Client) *AddCommentToTaskParams {
	o.SetHTTPClient(client)
	return o
}

// SetHTTPClient adds the HTTPClient to the add comment to task params
func (o *AddCommentToTaskParams) SetHTTPClient(client *http.Client) {
	o.HTTPClient = client
}

// WithBody adds the body to the add comment to task params
func (o *AddCommentToTaskParams) WithBody(body AddCommentToTaskBody) *AddCommentToTaskParams {
	o.SetBody(body)
	return o
}

// SetBody adds the body to the add comment to task params
func (o *AddCommentToTaskParams) SetBody(body AddCommentToTaskBody) {
	o.Body = body
}

// WithID adds the id to the add comment to task params
func (o *AddCommentToTaskParams) WithID(id int64) *AddCommentToTaskParams {
	o.SetID(id)
	return o
}

// SetID adds the id to the add comment to task params
func (o *AddCommentToTaskParams) SetID(id int64) {
	o.ID = id
}

// WriteToRequest writes these params to a swagger request
func (o *AddCommentToTaskParams) WriteToRequest(r runtime.ClientRequest, reg strfmt.Registry) error {

	r.SetTimeout(o.timeout)
	var res []error

	if err := r.SetBodyParam(o.Body); err != nil {
		return err
	}

	// path param id
	if err := r.SetPathParam("id", swag.FormatInt64(o.ID)); err != nil {
		return err
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}
