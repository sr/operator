Operator
========

Operator is a tool that for creating and maintaining ChatOps commands. It's
built around a few opinions on how to do that:

- Chat is just an interface to an automation server.
- Authentication and authorization rules are enforced server-side.
- The clients communicate with the server via a language-agnostic RPC protocol.
- Clients do not have access (account identifiers, tokens, ...) to the resources
  being automated. Only the server does.
- All operations are logged to an audit log and can always be attributed to an
  human or machine entity.
- There is at least one alternative client with the exact same feature set. This
  ensures that the chat bot is not a SPOF.

Checkout the [chatoops](/chatoops) directory for a complete example. It
demonstrates how to describe and implement an automation server and generate
[Hubot][] scripts and commond-line client.

**DISCLAIMER:** I have not used this in production yet. Consider this is a early
preview release. Ping @sr on Twitter or [open an issue][i] if you have any
question or feedback.

[protobuf]: https://developers.google.com/protocol-buffers/docs/proto3#services
[Hubot]: https://github.com/
[gRPC]: http://www.grpc.io/
[i]: https://github.com/sr/operator/issues/new
