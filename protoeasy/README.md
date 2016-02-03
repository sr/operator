[![CircleCI](https://circleci.com/gh/peter-edge/protoeasy-go/tree/master.png)](https://circleci.com/gh/peter-edge/protoeasy-go/tree/master)
[![Go Report Card](http://goreportcard.com/badge/peter-edge/protoeasy-go)](http://goreportcard.com/report/peter-edge/protoeasy-go)
[![Docker Repository on Quay](https://quay.io/repository/pedge/protoeasy/status)](https://quay.io/repository/pedge/protoeasy)
[![GoDoc](http://img.shields.io/badge/GoDoc-Reference-blue.svg)](https://godoc.org/go.pedge.io/protoeasy)
[![MIT License](http://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/peter-edge/protoeasy-go/blob/master/LICENSE)

Protoeasy is intended to make compiling protocol buffers files easier, and to optionally offload the compilation
to a server for consistency and so that protoc and any associated plugins do not have to be installed locally.

Instead of having to specify individual plugins and files, protoeasy operates on the concept of languages
and directories. Compilation is recommended to happen in a provided docker container. The primary language
developed for protoeasy was Go, and all gogo plugins are supported as well, but support also exists for C++,
C#, Objective-C, Python, and Ruby. gRPC support is built in for all supported languages. Proto3 is used as the
default compiler, however a proto2 docker container is also available, but support is limited.

Eventually, it would be nice to turn this into a full hosted service. If you would like to help, let me know :)

* [Quick Start](#quick-start)
* [Motivation](#motivation)
* [Tutorial](#tutorial)
  * [Installation](#installation)
  * [Short Introduction](#short-introduction)
  * [Basics](#basics)
  * [Go](#go)
  * [Automatically Imported Packages](#automatically-imported-packages)
  * [More Examples](#more-examples)
  * [Client/Server Setup](#clientserver-setup)
* [Future Work](#future-work)

### Quick Start

This assumes you are familiar with Go. I would recommend using Go 1.5.1 and having `GO15VENDOREXPERIMENT` set with `export GO15VENDOREXPERIMENT=1`.

Note that client/server mode is optional - you can use protoeasy locally if you have protoc and all relevant plugins installed.

```
# install binary
go get -v go.pedge.io/protoeasy/cmd/protoeasy
# OPTIONAL - if you have all the required binaries installed (protoc, plugins, etc), then you can use protoeasy locally
docker pull quay.io/pedge/protoeasy
docker run -d -p 6789:6789 quay.io/pedge/protoeasy
# Assuming you are running the docker daemon locally, DOCKER_ADDRESS is 0.0.0.0.
# Assuming you are running the docker daemon in a VM, DOCKER_ADDRESS is DOCKER_HOST without the port.
# Note that if you are running the docker daemon in a VM or remotely, port 6789 needs to be open for you to connect to
# DO NOT SET IF RUNNING LOCALLY
export PROTOEASY_ADDRESS="${DOCKER_ADDRESS}:6789"
# doing go as an example
# you do not need to cd in, but this is as an example
cd github.com/user/your-go-project
# this assumes your protocol buffers import paths are relative to the root of your go project
protoeasy --go --grpc --go-import-path github.com/user/your-go-project .
# compile for c++ and ruby too
protoeasy --go --grpc --go-import-path github.com/user/your-go-project --cpp --ruby .
# exclude protocol buffers files in foo/*
protoeasy --go --grpc --go-import-path github.com/user/your-go-project --exclude foo .
# this assumes your protocol buffers files are in ext/proto, and import paths are relative to ext/proto
protoeasy --go --grpc --go-import-path github.com/user/your-go-project/ext/proto ext/proto
```

### Motivation

Have you ever had one of the following issues:

* You're the resident protobuf expert on your team, and every time there is a change to a protocol buffers package
or you get a new teammate, you already know what the next hour of your life will be.
* You move to a new development machine, and can't remember how you got protoc installed properly, and now
your old build scripts do not work anymore.
* You upgrade proto3 on your computer, and suddenly protoc is broken.
* One of your teammates upgrades proto3 on their computer, and suddently protoc is broken.
* You did `go get -u google.golang.org/grpc`, or even worse, `google.golang.org` is a dependency
of some package and is updated, and suddenly new, incompatible `.pb.go` files are created.
* You have gRPC working on your mac, but linux is a mess.
* You use [Mosh](https://mosh.mit.edu/) and proto3, but since Mosh is still on proto2, you're in trouble.
* You're sick of resolving all relative paths to absolute paths or vice versa for `-I`.
* You really don't like having to edit a Makefile or script every time you add a protocol buffer file or package.
* You never can figure out a good scheme for a large amount of protocol buffers files and how to do imports properly.
* You think this protobuf thing is really cool, but are sick of maintaining large bash scripts or Makefile directives
to use protoc, and are sick of having to get everything installed on your development machine, and you know there must
be an easier way to do it but haven't found it yet.

Then protoeasy is for you!

### Tutorial

#### Installation

Install `protoeasy` using `make install`, assuming `${GOPATH}/bin` is on your `${PATH}`. You can also
do `go get -v go.pedge.io/protoeasy/cmd/protoeasy`.

#### Basics

Protoeasy compiles entire directories of protocol buffer files, as opposed to individual files. To use protoeasy:

* All protocol buffers files in the same sub-directory must have the same protocol buffers package.
* All imports must be relative to the base directory.

Both of these are already good practices. Assuming this structure, all you have to do is pass in a base directory,
and the rest is done for you. All `-I` directives are automatically figured out, and all protocol buffers files
in the same sub-directory are compiled together.

Instead of specifying individual output directives, protoeasy breaks compilation into separate languages, optionally
doing gRPC compilation for each language.

Assume we have a single file in our current directory called `foo.proto`.

```
syntax = "proto3";

package foo;

message One {
  int64 i = 1;
}
```

To compile for ruby, we would do:

```
protoeasy --ruby .
#protoc \
#  -I/tmp/protoeasy-input353662656 \
#  -I/go/src/go.pedge.io/protoeasy/vendor/go.pedge.io/pb/proto \
#  --ruby_out=/tmp/protoeasy-output452425503 \
#  /tmp/protoeasy-input353662656/foo.proto
```

To compile for ruby and c++, we would do:

```
protoeasy --ruby --cpp .
#protoc \
#  -I/tmp/protoeasy-input138072562 \
#  -I/go/src/go.pedge.io/protoeasy/vendor/go.pedge.io/pb/proto \
#  --cpp_out=/tmp/protoeasy-output084691625 \
#  /tmp/protoeasy-input138072562/foo.proto
#protoc \
#  -I/tmp/protoeasy-input138072562 \
#  -I/go/src/go.pedge.io/protoeasy/vendor/go.pedge.io/pb/proto \
#  --ruby_out=/tmp/protoeasy-output084691625 \
#  /tmp/protoeasy-input138072562/foo.proto
```

If we wanted to generate gRPC code for both, we would do:

```
protoeasy --ruby --cpp --grpc .
#protoc \
#  -I/tmp/protoeasy-input924418036 \
#  -I/go/src/go.pedge.io/protoeasy/vendor/go.pedge.io/pb/proto \
#  --cpp_out=/tmp/protoeasy-output335846083 \
#  --grpc_out=/tmp/protoeasy-output335846083 \
#  --plugin=protoc-gen-grpc=/usr/local/bin/grpc_cpp_plugin \
#  /tmp/protoeasy-input924418036/foo.proto
#protoc \
#  -I/tmp/protoeasy-input924418036 \
#  -I/go/src/go.pedge.io/protoeasy/vendor/go.pedge.io/pb/proto \
#  --ruby_out=/tmp/protoeasy-output335846083 \
#  --grpc_out=/tmp/protoeasy-output335846083 \
#  --plugin=protoc-gen-grpc=/usr/local/bin/grpc_ruby_plugin \
#  /tmp/protoeasy-input924418036/foo.proto
```

What is going on here:

* For each language, a protoc command is generated. Each language is run separately because
some protoc flags overlap (`--plugin` specifically).
* The `/tmp/protoeasy-input...` directories are the directory where `foo.proto` is located. These
compilations were done on a remote server, explained later.
* If `--grpc` is specified, `--grpc_out` and `--plugin` flags are specified for each associated language,
except for Go which has different logic.
* Other typical imports are added automatically, explained later.

Supported languages are C++, C#, Objective-C, Python, Ruby, and Go. Protoeasy was primarily developed for Go
(which is what I use it for), so if there are idioms for other languages, let me know.

#### Go

Go has special handling. Let's assume we have our original `foo.proto`, and another file `bar/bar.proto` in the
sub-directory `bar`, and let's assume these are in the Go package `github.com/alice/helloworld`.

```
syntax = "proto3";

import "google/api/annotations.proto";
import "google/protobuf/empty.proto";
import "foo.proto";

package bar;

message Two {
  foo.One one = 1;
  int64 j = 2;
}

service API {
  rpc Do(Two) returns (google.protobuf.Empty) {
    option (google.api.http) = {
      post: "/do"
      body: "*"
    };
  }
}
```

Let's compile these with go, grpc, and [grpc-gateway](https://github.com/gengo/grpc-gateway), and do them all now
without building up the example so that this README does not get too long.

```
protoeasy --go --go-import-path=github.com/alice/helloworld --grpc --grpc-gateway .
#protoc \
#  -I/tmp/protoeasy-input035188496 \
#  -I/go/src/go.pedge.io/protoeasy/vendor/go.pedge.io/pb/proto \
#  --go_out=Mbar/bar.proto=github.com/alice/helloworld/bar,Mfoo.proto=github.com/alice/helloworld,Mgoogle/api/annotations.proto=github.com/gengo/grpc-gateway/third_party/pb/go/google/api,Mgoogle/api/http.proto=github.com/gengo/grpc-gateway/third_party/pb/go/google/api,Mgoogle/datastore/v1beta3/datastore.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/datastore/v1beta3/entity.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/datastore/v1beta3/query.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/devtools/cloudtrace/v1/trace.proto=go.pedge.io/pb/go/google/devtools/cloudtrace/v1,Mgoogle/example/library/v1/library.proto=go.pedge.io/pb/go/google/example/library/v1,Mgoogle/iam/v1/iam_policy.proto=go.pedge.io/pb/go/google/iam/v1,Mgoogle/iam/v1/policy.proto=go.pedge.io/pb/go/google/iam/v1,Mgoogle/longrunning/operations.proto=go.pedge.io/pb/go/google/longrunning,Mgoogle/protobuf/any.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/api.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/empty.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/field_mask.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/source_context.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/struct.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/timestamp.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/type.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/wrappers.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/pubsub/v1/pubsub.proto=go.pedge.io/pb/go/google/pubsub/v1,Mgoogle/pubsub/v1beta2/pubsub.proto=go.pedge.io/pb/go/google/pubsub/v1beta2,Mgoogle/rpc/code.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/rpc/error_details.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/rpc/status.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/type/color.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/date.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/dayofweek.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/latlng.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/money.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/timeofday.proto=go.pedge.io/pb/go/google/type,plugins=grpc:/tmp/protoeasy-output215726383 \
#  --grpc-gateway_out=Mbar/bar.proto=github.com/alice/helloworld/bar,Mfoo.proto=github.com/alice/helloworld,Mgoogle/api/annotations.proto=github.com/gengo/grpc-gateway/third_party/pb/go/google/api,Mgoogle/api/http.proto=github.com/gengo/grpc-gateway/third_party/pb/go/google/api,Mgoogle/datastore/v1beta3/datastore.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/datastore/v1beta3/entity.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/datastore/v1beta3/query.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/devtools/cloudtrace/v1/trace.proto=go.pedge.io/pb/go/google/devtools/cloudtrace/v1,Mgoogle/example/library/v1/library.proto=go.pedge.io/pb/go/google/example/library/v1,Mgoogle/iam/v1/iam_policy.proto=go.pedge.io/pb/go/google/iam/v1,Mgoogle/iam/v1/policy.proto=go.pedge.io/pb/go/google/iam/v1,Mgoogle/longrunning/operations.proto=go.pedge.io/pb/go/google/longrunning,Mgoogle/protobuf/any.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/api.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/empty.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/field_mask.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/source_context.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/struct.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/timestamp.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/type.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/wrappers.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/pubsub/v1/pubsub.proto=go.pedge.io/pb/go/google/pubsub/v1,Mgoogle/pubsub/v1beta2/pubsub.proto=go.pedge.io/pb/go/google/pubsub/v1beta2,Mgoogle/rpc/code.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/rpc/error_details.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/rpc/status.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/type/color.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/date.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/dayofweek.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/latlng.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/money.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/timeofday.proto=go.pedge.io/pb/go/google/type:/tmp/protoeasy-output215726383 \
#  /tmp/protoeasy-input035188496/bar/bar.proto
#protoc \
#  -I/tmp/protoeasy-input035188496 \
#  -I/go/src/go.pedge.io/protoeasy/vendor/go.pedge.io/pb/go/google/protobuf \
#  --go_out=Mbar/bar.proto=github.com/alice/helloworld/bar,Mfoo.proto=github.com/alice/helloworld,Mgoogle/api/annotations.proto=github.com/gengo/grpc-gateway/third_party/pb/go/google/api,Mgoogle/api/http.proto=github.com/gengo/grpc-gateway/third_party/pb/go/google/api,Mgoogle/datastore/v1beta3/datastore.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/datastore/v1beta3/entity.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/datastore/v1beta3/query.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/devtools/cloudtrace/v1/trace.proto=go.pedge.io/pb/go/google/devtools/cloudtrace/v1,Mgoogle/example/library/v1/library.proto=go.pedge.io/pb/go/google/example/library/v1,Mgoogle/iam/v1/iam_policy.proto=go.pedge.io/pb/go/google/iam/v1,Mgoogle/iam/v1/policy.proto=go.pedge.io/pb/go/google/iam/v1,Mgoogle/longrunning/operations.proto=go.pedge.io/pb/go/google/longrunning,Mgoogle/protobuf/any.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/api.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/empty.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/field_mask.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/source_context.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/struct.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/timestamp.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/type.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/wrappers.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/pubsub/v1/pubsub.proto=go.pedge.io/pb/go/google/pubsub/v1,Mgoogle/pubsub/v1beta2/pubsub.proto=go.pedge.io/pb/go/google/pubsub/v1beta2,Mgoogle/rpc/code.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/rpc/error_details.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/rpc/status.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/type/color.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/date.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/dayofweek.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/latlng.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/money.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/timeofday.proto=go.pedge.io/pb/go/google/type,plugins=grpc:/tmp/protoeasy-output215726383 \
#  --grpc-gateway_out=Mbar/bar.proto=github.com/alice/helloworld/bar,Mfoo.proto=github.com/alice/helloworld,Mgoogle/api/annotations.proto=github.com/gengo/grpc-gateway/third_party/pb/go/google/api,Mgoogle/api/http.proto=github.com/gengo/grpc-gateway/third_party/pb/go/google/api,Mgoogle/datastore/v1beta3/datastore.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/datastore/v1beta3/entity.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/datastore/v1beta3/query.proto=go.pedge.io/pb/go/google/datastore/v1beta3,Mgoogle/devtools/cloudtrace/v1/trace.proto=go.pedge.io/pb/go/google/devtools/cloudtrace/v1,Mgoogle/example/library/v1/library.proto=go.pedge.io/pb/go/google/example/library/v1,Mgoogle/iam/v1/iam_policy.proto=go.pedge.io/pb/go/google/iam/v1,Mgoogle/iam/v1/policy.proto=go.pedge.io/pb/go/google/iam/v1,Mgoogle/longrunning/operations.proto=go.pedge.io/pb/go/google/longrunning,Mgoogle/protobuf/any.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/api.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/empty.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/field_mask.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/source_context.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/struct.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/timestamp.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/type.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/protobuf/wrappers.proto=go.pedge.io/pb/go/google/protobuf,Mgoogle/pubsub/v1/pubsub.proto=go.pedge.io/pb/go/google/pubsub/v1,Mgoogle/pubsub/v1beta2/pubsub.proto=go.pedge.io/pb/go/google/pubsub/v1beta2,Mgoogle/rpc/code.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/rpc/error_details.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/rpc/status.proto=go.pedge.io/pb/go/google/rpc,Mgoogle/type/color.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/date.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/dayofweek.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/latlng.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/money.proto=go.pedge.io/pb/go/google/type,Mgoogle/type/timeofday.proto=go.pedge.io/pb/go/google/type:/tmp/protoeasy-output215726383 \
#  /tmp/protoeasy-input035188496/foo.proto
```

Whoa! There's a lot going on there, let's walk through it:

* The `-I` directives are the same as other languages.
* For gRPC, instead of having `--grpc_out` and `--plugin`, Go does `--go_out=plugins=grpc`
* We specified that we are in the `github.com/alice/helloworld` package using `--go-import-path` and the modifiers
`Mbar/bar.proto=github.com/alice/helloworld/bar,Mfoo.proto=github.com/alice/helloworld` were generated for us. Therefore `bar.pb.go` 
has the import statement `import foo "github.com/alice/helloworld"`. If, instead, all protocol buffers files were
in a sub-directory `proto` in `github.com/alice/helloworld`, we would have done `protoeasy --go --grpc --grpc_gateway --go-import-path github.com/alice/helloworld/proto proto` 
* We have the modifiers for a bunch of other files, but specifically `Mgoogle/api/annotations.proto=github.com/gengo/grpc-gateway/third_party/googleapis/google/api,Mgoogle/protobuf/empty.proto=go.pedge.io/pb/go`. More on this later.
* The directive `--grpc-gateway_out` created a `bar/bar.pb.gw.go` file for us, for grpc-gateway. You should really check grpc-gateway out :)

Other Go flags:

* `--go-protoc-plugin=`: specifiy a plugin other than `protoc-gen-go`. This is useful for gogo.
* `--go-modifier`: specify an additional modifier of the form `Mfile=package`.
* `--go-no-default-modifiers`: do not use the default modifiers for google/protobuf and googleapis.

#### Automatically Imported Packages

Protoeasy automatically imports the protocol buffers files in:

* https://github.com/google/protobuf/tree/master/src/google/protobuf, done using https://go.pedge.io/pb. These are the well-known types, and you should really check them out! google/protobuf/descriptor.proto is done from https://github.com/golang/protobuf/tree/master/protoc-gen-go/descriptor to be compatible with Go imports, but is the same file.
* https://github.com/google/googleapis, done using https://go.pedge.io/pb. google/api/annotations.proto and google/api/http.proto are done using https://github.com/gengo/grpc-gateway/tree/master/third_party/googleapis/google/api.

Track https://github.com/golang/protobuf/issues/50 for more details.

#### More Examples

See `make proto` and `make example-complete` for two more example usages. I also use protoeasy for all my public Go projects on GitHub that use protocol buffers (the command using protoeasy is in the Makefile in each project):

* https://go.pedge.io/dockerplugin
* https://go.pedge.io/dockervolume
* https://go.pedge.io/flightaware
* https://go.pedge.io/openflights
* https://go.pedge.io/pkg
* https://go.pedge.io/proto

#### Client/Server Setup

Protoeasy works on your local machine by default, however this is not how it is intended to be used. Protoeasy provides
a Docker image `quay.io/pedge/protoeasy`, created from the [Dockerfile](Dockerfile) in this repository, that has everything
necessary for compilation already installed, and which runs the [protoeasyd](cmd/protoeasyd) daemon. The `protoeasy` binary
will automatically connect to this daemon and delegate compilation if the environment variable `PROTOEASY_ADDRESS` is set.

How this works:

* The client (`protoeasy`) tarballs all `.proto` files in the specified directory and uploads this tarball to the server,
along with the directives given from the flags.
* The server creates two temporary directories, one for the uploaded tarball, and one to output generated files.
* The server untars the uploaded tarball, runs the `protoeasy` logic, and outputs the generated files.
* The server tarballs the generated files, and sends them back to the client.
* The client untars the generated files in the specified directory.

To use this, first get the Docker image:

```
docker pull quay.io/pedge/protoeasy
```

Or, build it from this repository:

```
make docker-build
```

Then launch the daemon:

```
docker run -d -p 6789:6789 quay.io/pedge/protoeasy # or do make docker-launch
```

My local setup is a Macbook Pro with Docker running in a VirtualBox VM with a private network at 192.168.10.10.

```ruby
# a simple version from my Vagrantfile at https://github.com/peter-edge/dotfiles/blob/master/vagrant/common/base_provision.rb
Vagrant.configure(2) do |config|
  ...
  config.vm.network "private_network", ip: "192.168.10.10"
end
```

```
# on my vagrant host, this was setup using https://github.com/peter-edge/dotfiles/blob/master/bin/setup_docker_http_upstart.sh
ps -ef | grep docker
#root     16450     1  0 Nov28 ?        00:06:01 /usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
```

Many Docker VirtualBox setups are similar to this, including I believe the one created from Docker Machine.

In my `~/.bash_aliases`, I have:

```
export PROTOEASY_ADDRESS=192.168.10.10:6789

launch-protoeasy() {
  docker rm -f protoeasy || true
  docker run -d -p 6789:6789 --name=protoeasy quay.io/pedge/protoeasy
}
```

Whenever protoeasy is stopped, or when I want to restart it, I just run `launch-protoeasy`. Since I have `PROTOEASY_ADDRESS` exported, the `protoeasy` binary always connects to the running Docker container.

In this manner, I never actually compile protocol buffers files on my Macbook directly.

**Q**: Why not just do your builds directly in a Docker container, i.e. `docker run --volume $(pwd):/compile --workdir /compile pedge/proto3grpc protoc --go_out=. foo.proto` https://hub.docker.com/r/pedge/proto3grpc  
**A**: This is what I used to do, but if your Docker host is NOT local (i.e. you are not using Docker locally in Linux, or in a local VM), this means that you cannot have a host volume linking. Protoeasy should soon have a deployment option once I get TLS added. Also, protoeasy is a little faster, but it's not really important.

### Future Work

Protoeasy is brand new, and has a long way to go. Main areas:

* Make sure compilation for non-Go languages is correct.
* Get security added for public deployment.
* Get an easy deployment option (probably Kubernetes) added.

If you want to help, let me know!
