Operator
========

Welcome to Operator, a tool that aids developing and maintaining ChatOps commands
backed by RPC services.

Given a set of [Protocol Buffers][protobuf] service definitions (`.proto` files)
it generates:

- [Hubot][] scripts for interacting with all RPC services through chat.
- A command-line program that's equivalent to the Hubot scripts except that it
works even when chat is down.
- A [gRPC][] server daemon exposing all services for both clients to connect to.
Automatically logs all requests (audit log).

Checkout the [chatoops](/chatoops) directory for a complete example showing how
to implement services and what the generated code looks like. Also includes a
Makefile demonstrating how to install and use this project.

**DISCLAIMER:** This project hasn't been used in production yet and is very
much unstable. Consider this is a verly early preview release. Ping @sr on
Twitter or open an issue if you have any question or feedback.

[protobuf]: https://developers.google.com/protocol-buffers/docs/proto3#services
[Hubot]: https://github.com/
[gRPC]: http://www.grpc.io/
