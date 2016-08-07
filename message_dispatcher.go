package operator

import (
	"fmt"
	"regexp"
	"strings"

	"google.golang.org/grpc"
)

const rCommandMessage = `\A%s(?P<service>\w+)\s+(?P<method>\w+)(?:\s+(?P<options>.*))?\z`

type messageDispatcher struct {
	logger  Logger
	conn    *grpc.ClientConn
	re      *regexp.Regexp
	invoker Invoker
}

func newMessageDispatcher(
	logger Logger,
	conn *grpc.ClientConn,
	prefix string,
	invoker Invoker,
) (*messageDispatcher, error) {
	r, err := regexp.Compile(fmt.Sprintf(rCommandMessage, prefix))
	if err != nil {
		return nil, err
	}
	return &messageDispatcher{
		logger,
		conn,
		r,
		invoker,
	}, nil
}

func (d *messageDispatcher) Dispatch(msg *Message) (bool, error) {
	matches := d.re.FindStringSubmatch(msg.Text)
	if matches == nil {
		return false, nil
	}
	call := strings.Join(matches[1:2], " ")
	// TODO(sr) Parse options opts := matches[3]
	return d.invoker(d.conn, call, msg)
}
