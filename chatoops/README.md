# ChatOops

This is an example Operator project.

The user writes services definitions in the [Protocol Buffers][protobuf]
language. The `operatorc` program then generates one Hubot scripts per service
and a singe command-line program to interact with the services.

Example service definition and implementation, written by a human:

- [buildkite.proto](/chatoops/services/buildkite/buildkite.proto)
- [api_server.go](/chatoops/services/buildkite/api_server.go)

All the rest is generated with this command:

```
$ operatorc \
    --import-path github.com/sr/operator/chatoops/services \
    --cmd-out cmd/operator \
    --hubot-out hubot/scripts \
    --server-out cmd/operatord \
    services/**/*.proto
```

- Hubot script:
  [buildkite.js](/chatoops/hubot/scripts/buildkite-gen.js)
- command-line client program:
  [`chatoops/cmd/operator/main-gen.go`](/chatoops/cmd/operator/main-gen.go)
- The [gRPC][] server that exposes the services implementations over the
  network and logs operations:
  [`chatoops/cmd/operatord/main-gen.go`](/chatoops/cmd/operatord/main-gen.go)

Checkout the [Makefile](/chatoops/Makefile) for details on how to compile and
run the generated code.

[protobuf]: https://developers.google.com/protocol-buffers/docs/proto3#services
[Hubot]: https://github.com/
[gRPC]: http://www.grpc.io/
