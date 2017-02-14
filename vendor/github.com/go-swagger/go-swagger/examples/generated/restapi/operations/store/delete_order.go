package store

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the generate command

import (
	"net/http"

	middleware "github.com/go-openapi/runtime/middleware"
)

// DeleteOrderHandlerFunc turns a function with the right signature into a delete order handler
type DeleteOrderHandlerFunc func(DeleteOrderParams) middleware.Responder

// Handle executing the request and returning a response
func (fn DeleteOrderHandlerFunc) Handle(params DeleteOrderParams) middleware.Responder {
	return fn(params)
}

// DeleteOrderHandler interface for that can handle valid delete order params
type DeleteOrderHandler interface {
	Handle(DeleteOrderParams) middleware.Responder
}

// NewDeleteOrder creates a new http.Handler for the delete order operation
func NewDeleteOrder(ctx *middleware.Context, handler DeleteOrderHandler) *DeleteOrder {
	return &DeleteOrder{Context: ctx, Handler: handler}
}

/*DeleteOrder swagger:route DELETE /stores/order/{orderId} store deleteOrder

Delete purchase order by ID

For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors

*/
type DeleteOrder struct {
	Context *middleware.Context
	Handler DeleteOrderHandler
}

func (o *DeleteOrder) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	route, _ := o.Context.RouteInfo(r)
	var Params = NewDeleteOrderParams()

	if err := o.Context.BindValidRequest(r, route, &Params); err != nil { // bind params
		o.Context.Respond(rw, r, route.Produces, route, err)
		return
	}

	res := o.Handler.Handle(Params) // actually handle the request

	o.Context.Respond(rw, r, route.Produces, route, res)

}
