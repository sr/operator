[![CircleCI](https://circleci.com/gh/peter-edge/openflights-go/tree/master.png)](https://circleci.com/gh/peter-edge/openflights-go/tree/master)
[![Go Report Card](http://goreportcard.com/badge/peter-edge/openflights-go)](http://goreportcard.com/report/peter-edge/openflights-go)
[![GoDoc](http://img.shields.io/badge/GoDoc-Reference-blue.svg)](https://godoc.org/go.pedge.io/openflights)
[![MIT License](http://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/peter-edge/openflights-go/blob/master/LICENSE)

### Please donate to OpenFlights!

If you do use this, I ask you to donate to OpenFlights, the source for all the data
in here as of now, at http://openflights.org/donate. Seriously, if you can afford it, the OpenFlights
team is responsible for putting all this data together and maintaining it, and we owe it to them
to support their work.

## Introduction

Note the custom import path!

```go
import (
  "go.pedge.io/openflights"
)
```

Openflights is a package that exposes the data from http://openflights.org/data.html, available within
https://github.com/jpatokal/openflights/tree/master/data.

Flights uses [protobuf](https://developers.google.com/protocol-buffers/docs/proto3) and [gRPC](http://www.grpc.io) to auto-generate
a protobuf/grpc API stubs, and a HTTP/JSON API. See [openflights.proto](openflights.proto) for the API definition. The HTTP endpoints
should be relatively straightfoward.

The binary [openflightsd](cmd/openflightsd) is a server binary that hosts the API. `make install` will install this, which you can
then run with `${GOPATH}/bin/openflightsd`, or `make launch` will build a Docker image that is ~13MB as of now, and launch
this Docker image with the default ports set. Then, you can `curl http://0.0.0.0:8080/api/airports/code/sfo` as a quick check.

The openflights package for golang adds some golang-specific additional functionality around the generated protocol buffers code.
See [openflights.go](openflights.go) for publically-exposed structures.

The binaries [gen-openflights-csv-store](cmd/gen-openflights-csv-store) and [gen-openflights-id-store](cmd/gen-openflights-id-store) will generate
the data for you in either a `CSVStore` or `IDStore`. Note that this is how [generated.go](generated.go) is generated.

The binary [openflights](cmd/openflights) is a CLI for the server. If `OPENFLIGHTS_ADDRESS` is set, this will connect to a running
instance of `openflightsd`:

```
$ OPENFLIGHTS_ADDRESS=0.0.0.0:1747 openflights miles --min 500 vie-bru-ewr/mem-ord-ams-vie
```

Otherwise, this will create an effective server inside the CLI, doing all the initial calculations (slower):

```
$ openflights miles --min 500 vie-bru-ewr
```

The only command available right now is `miles`, which will calculate the miles of a route, given by space-separated
airport codes. The flag `--min` will use a minimum miles for a segment, useful for airline mileage calculations.

```
$ openflights miles --min 500 vie-bru-ewr-mem-ord-ams-vie
VIE-BRU 574mi
BRU-EWR 3670mi
EWR-MEM 944mi
MEM-ORD 500mi (492mi actual)
ORD-AMS 4108mi
AMS-VIE 596mi

10392mi (10384mi actual)
20784mi round trip (20768mi actual)
```

## Future Work

Please contact me if you want to help out!
