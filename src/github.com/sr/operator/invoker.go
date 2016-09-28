package operator

import (
	"time"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

type invoker struct {
	conn    *grpc.ClientConn
	timeout time.Duration
	inst    Instrumenter
	replier Replier
	f       InvokerFunc
}

func (i *invoker) Invoke(ctx context.Context, msg *Message, req *Request) {
	ctx, cancel := context.WithTimeout(ctx, i.timeout)
	defer cancel()
	errC := make(chan error, 1)
	go func() {
		_, err := i.f(ctx, i.conn, req)
		errC <- err
	}()
	event := &Event{
		Key:     "invoker",
		Request: req,
		Message: msg,
	}
	select {
	case <-ctx.Done():
		event.Error = ctx.Err()
	case err := <-errC:
		event.Error = err
	}
	if i.inst != nil {
		i.inst.Instrument(event)
	}
	if i.replier != nil && req.ReplierId != "" && req.GetSource() != nil {
		if err := i.replier.Reply(
			ctx,
			req.GetSource(),
			req.ReplierId,
			&Message{Text: grpc.ErrorDesc(event.Error)},
		); err != nil {
			event.Key = "invoker_replier_error"
			event.Error = err
			i.inst.Instrument(event)
		}
	}
}
