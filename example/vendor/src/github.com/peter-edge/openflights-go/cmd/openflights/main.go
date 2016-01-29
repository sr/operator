package main

import (
	"encoding/json"
	"os"
	"strings"

	"github.com/gogo/protobuf/proto"
	"github.com/kr/pretty"
	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
	"go.pedge.io/env"
	"go.pedge.io/openflights"
	"go.pedge.io/pkg/cobra"
	"google.golang.org/grpc"
)

type appEnv struct {
	Address string `env:"OPENFLIGHTS_ADDRESS"`
}

func main() {
	env.Main(do, &appEnv{})
}

func do(appEnvObj interface{}) error {
	appEnv := appEnvObj.(*appEnv)

	flags := &flags{}

	airportCmd := &cobra.Command{
		Use:   "airport codes...",
		Short: "Get information for the specified airports",
		Long:  "Get information for the specified airports",
		RunE: func(_ *cobra.Command, args []string) error {
			client, err := getClient(appEnv.Address)
			if err != nil {
				return err
			}
			for _, arg := range args {
				airport, err := client.GetAirport(arg)
				if err != nil {
					return err
				}
				if err := printSingle(airport); err != nil {
					return err
				}
			}
			return nil
		},
	}

	airlineCmd := &cobra.Command{
		Use:   "airline codes...",
		Short: "Get information for the specified airlines",
		Long:  "Get information for the specified airlines",
		RunE: func(_ *cobra.Command, args []string) error {
			client, err := getClient(appEnv.Address)
			if err != nil {
				return err
			}
			for _, arg := range args {
				airline, err := client.GetAirline(arg)
				if err != nil {
					return err
				}
				if err := printSingle(airline); err != nil {
					return err
				}
			}
			return nil
		},
	}

	routesCmd := &cobra.Command{
		Use:   "routes airline source dest",
		Short: "Get routes for the giben airline, source airport, and destination airport",
		Long:  "Get routes for the giben airline, source airport, and destination airport",
		RunE: func(_ *cobra.Command, args []string) error {
			if err := pkgcobra.CheckFixedArgs(3, args); err != nil {
				return err
			}
			client, err := getClient(appEnv.Address)
			if err != nil {
				return err
			}
			routes, err := client.GetRoutes(args[0], args[1], args[2])
			if err != nil {
				return err
			}
			for _, route := range routes {
				if err := printSingle(route); err != nil {
					return err
				}
			}
			return nil
		},
	}

	milesCmd := &cobra.Command{
		Use:   "miles vie-ewr-iad/jfk-vie",
		Short: "Get the miles for the given route specified by the airport codes",
		Long:  "Get the miles for the given route specified by the airport codes",
		RunE: func(_ *cobra.Command, args []string) error {
			client, err := getClient(appEnv.Address)
			if err != nil {
				return err
			}
			response, err := client.GetMiles(
				&openflights.GetMilesRequest{
					Route:      strings.Join(args, " "),
					MinMiles:   flags.minMiles,
					Percentage: flags.percentage,
				},
			)
			if err != nil {
				return err
			}
			return openflights.PrettyPrintGetMilesResponse(os.Stdout, response)
		},
	}
	flags.bindMinMiles(milesCmd.Flags())
	flags.bindPercentage(milesCmd.Flags())

	rootCmd := &cobra.Command{
		Use:   "app",
		Short: "Openflights client command",
		Long:  "Openflights client command",
	}
	rootCmd.AddCommand(airportCmd)
	rootCmd.AddCommand(airlineCmd)
	rootCmd.AddCommand(routesCmd)
	rootCmd.AddCommand(milesCmd)

	return rootCmd.Execute()
}

func getClient(address string) (openflights.Client, error) {
	if address != "" {
		clientConn, err := grpc.Dial(address, grpc.WithInsecure())
		if err != nil {
			return nil, err
		}
		return openflights.NewClient(openflights.NewAPIClient(clientConn)), nil
	}
	return openflights.NewDefaultServerClient()
}

func printSingle(message proto.Message) error {
	data, err := json.Marshal(message)
	if err != nil {
		return err
	}
	_, err = pretty.Println(string(data))
	return err
}

type flags struct {
	minMiles   uint32
	percentage uint32
}

func (f *flags) bindMinMiles(flagSet *pflag.FlagSet) {
	flagSet.Uint32Var(&f.minMiles, "min", 0, "The minimum miles for a segment in a route calcuation.")
}

func (f *flags) bindPercentage(flagSet *pflag.FlagSet) {
	flagSet.Uint32Var(&f.percentage, "percentage", 100, "The percentage to multiply fly routes by.")
}
