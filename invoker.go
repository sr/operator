package operator

import (
	"fmt"
	"strings"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

type invoker struct {
	conn    *grpc.ClientConn
	timeout time.Duration
	inst    Instrumenter
	sender  Sender
	f       InvokerFunc
	pkg     string
	msgOpts interface{}
}

func (i *invoker) Invoke(ctx context.Context, msg *Message, req *Request) {
	ctx, cancel := context.WithTimeout(ctx, i.timeout)
	defer cancel()
	errC := make(chan error, 1)
	go func() {
		errC <- i.f(ctx, i.conn, req, i.pkg)
	}()
	event := &Event{Key: "invoker", Request: req, Message: msg}
	select {
	case <-ctx.Done():
		event.Error = fmt.Errorf("RPC request failed to complete within %s", i.timeout)
	case err := <-errC:
		event.Error = err
	}
	if event.Error != nil &&
		i.sender != nil &&
		req != nil &&
		!strings.Contains(event.Error.Error(), "no such service:") {
		if err := i.sender.Send(ctx, req.GetSource(), req.SenderId, &Message{
			Text:    grpc.ErrorDesc(event.Error),
			HTML:    fmt.Sprintf("Request failed: <code>%s</code>", grpc.ErrorDesc(event.Error)),
			Options: i.msgOpts,
		}); err != nil {
			i.inst.Instrument(&Event{
				Key:     "invoker_sender_error",
				Request: req,
				Message: msg,
				Error:   err,
			})
		}
	}
	if i.inst != nil {
		i.inst.Instrument(event)
	}
}
