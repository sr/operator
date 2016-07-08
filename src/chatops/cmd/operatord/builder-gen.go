// Code generated by protoc-gen-operatord
package main

import (
	"errors"
	"flag"
	"os"
	"strings"

	"google.golang.org/grpc"

	"chatops/services/ping"
)

func buildOperatorServer(
	server *grpc.Server,
	flags *flag.FlagSet,
) (map[string]error, error) {
	pingerConfig := &pinger.PingerConfig{}
	services := make(map[string]error)
	if err := flags.Parse(os.Args[1:]); err != nil {
		return services, err
	}
	errs := make(map[string][]string)
	if len(errs["pinger"]) != 0 {
		services["pinger"] = errors.New("required flag(s) missing: " + strings.Join(errs["pinger"], ", "))
	} else {
		pingerServer, err := pinger.NewAPIServer(pingerConfig)
		if err != nil {
			services["pinger"] = err
		} else {
			pinger.RegisterPingerServer(server, pingerServer)
			services["pinger"] = nil
		}
	}
	return services, nil
}