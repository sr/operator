package user

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the generate command

import (
	"net/http"

	middleware "github.com/go-openapi/runtime/middleware"
)

// CreateUsersWithArrayInputHandlerFunc turns a function with the right signature into a create users with array input handler
type CreateUsersWithArrayInputHandlerFunc func(CreateUsersWithArrayInputParams) middleware.Responder

// Handle executing the request and returning a response
func (fn CreateUsersWithArrayInputHandlerFunc) Handle(params CreateUsersWithArrayInputParams) middleware.Responder {
	return fn(params)
}

// CreateUsersWithArrayInputHandler interface for that can handle valid create users with array input params
type CreateUsersWithArrayInputHandler interface {
	Handle(CreateUsersWithArrayInputParams) middleware.Responder
}

// NewCreateUsersWithArrayInput creates a new http.Handler for the create users with array input operation
func NewCreateUsersWithArrayInput(ctx *middleware.Context, handler CreateUsersWithArrayInputHandler) *CreateUsersWithArrayInput {
	return &CreateUsersWithArrayInput{Context: ctx, Handler: handler}
}

/*CreateUsersWithArrayInput swagger:route POST /users/createWithArray user createUsersWithArrayInput

Creates list of users with given input array

*/
type CreateUsersWithArrayInput struct {
	Context *middleware.Context
	Handler CreateUsersWithArrayInputHandler
}

func (o *CreateUsersWithArrayInput) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	route, _ := o.Context.RouteInfo(r)
	var Params = NewCreateUsersWithArrayInputParams()

	if err := o.Context.BindValidRequest(r, route, &Params); err != nil { // bind params
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}

	res := o.Handler.Handle(Params) // actually handle the request

	o.Context.Respond(rw, r, route.Produces, route, res)

}
