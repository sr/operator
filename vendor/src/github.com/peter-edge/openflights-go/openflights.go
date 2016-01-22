/*
Package openflights exposes various flight data from OpenFlights.org.


If you do use this package, I ask you to donate to OpenFlights, the source for all the data
in here as of now, at http://openflights.org/donate. Seriously, if you can afford it, the OpenFlights
team is responsible for putting all this data together and maintaining it, and we owe it to them
to support their work.
*/
package openflights // import "go.pedge.io/openflights"
import (
	"fmt"
	"io"
	"strings"
)

// GetCSVStore gets the CSVStore from GitHub.
func GetCSVStore() (*CSVStore, error) {
	return getCSVStore()
}

// NewIDStore creates a new IDStore from a CSVStore.
func NewIDStore(csvStore *CSVStore) (*IDStore, error) {
	return newIDStore(csvStore)
}

// CodeStore is a mapping for airline/airport codes (ICAO or IATA/FAA) to object.
//
// Duplicates may be filtered, ie there may be airlines/airports in a CSVStore or IDStore
// that are not present in this structure.
type CodeStore struct {
	CodeToAirport              map[string]*Airport
	CodeToAirline              map[string]*Airline
	AirlineToRoutes            map[string][]*Route
	SourceAirportToRoutes      map[string][]*Route
	DestinationAirportToRoutes map[string][]*Route
}

// CodeStoreOptions are options for a CodeStore.
type CodeStoreOptions struct {
	// if set, duplicates will not be filtered
	NoFilterDuplicates bool
	// if set, an error will not be returned on a duplicate
	NoErrorOnDuplicates bool
}

// NewCodeStore creates a new CodeStore from an IDStore.
func NewCodeStore(idStore *IDStore, options CodeStoreOptions) (*CodeStore, error) {
	return newCodeStore(idStore, options)
}

// IDClient is the client to interface with flights data by ID.
type IDClient interface {
	// callbackErr will return nil or an error after out is closed or cancel is called (which in turn closes out)
	GetAllAirports() (out <-chan *Airport, cancel chan<- bool, callbackErr <-chan error, err error)
	// callbackErr will return nil or an error after out is closed or cancel is called (which in turn closes out)
	GetAllAirlines() (out <-chan *Airline, cancel chan<- bool, callbackErr <-chan error, err error)
	// callbackErr will return nil or an error after out is closed or cancel is called (which in turn closes out)
	GetAllRoutes() (out <-chan *Route, cancel chan<- bool, callbackErr <-chan error, err error)
	GetAirportByID(id string) (*Airport, error)
	GetAirlineByID(id string) (*Airline, error)
}

// CodeClient is the client to interface with flights data by ICAO/IATA/FAA code.
type CodeClient interface {
	GetAirportByCode(code string) (*Airport, error)
	GetAirlineByCode(code string) (*Airline, error)
	GetRoutes(airlineIDOrCode string, sourceAirportIDOrCode string, destinationAirportIDOrCode string) ([]*Route, error)
}

// Client is the client to interface with flights data.
type Client interface {
	IDClient
	CodeClient
	GetAirport(idOrCode string) (*Airport, error)
	GetAirline(idOrCode string) (*Airline, error)
	GetDistance(sourceAirportIDOrCode string, destinationAirportIDOrCode string) (uint32, error)
	GetMiles(*GetMilesRequest) (*GetMilesResponse, error)
}

// NewClient creates a new Client that calles the given APIClient.
func NewClient(apiClient APIClient) Client {
	return newClient(apiClient)
}

// NewLocalAPIClient creates a new APIClient using the given APIServer.
func NewLocalAPIClient(apiServer APIServer) APIClient {
	return newLocalAPIClient(apiServer)
}

// NewAPIServer creates a new APIServer using the given Client.
func NewAPIServer(client Client) APIServer {
	return newLogAPIServer(newAPIServer(client))
}

// NewServerClient creates a new server-side Client.
func NewServerClient(idStore *IDStore, options CodeStoreOptions) (Client, error) {
	codeStore, err := newCodeStore(idStore, options)
	if err != nil {
		return nil, err
	}
	return newServerClient(idStore, codeStore)
}

// NewDefaultServerClient creates a new server-side Client from the generated CSVStore.
func NewDefaultServerClient() (Client, error) {
	idStore, err := newIDStore(_GlobalCSVStore)
	if err != nil {
		return nil, err
	}
	return NewServerClient(idStore, CodeStoreOptions{})
}

// Codes returns the airport codes.
func (airport *Airport) Codes() []string {
	if airport.IataFaa == airport.Icao {
		if airport.IataFaa == "" {
			return []string{}
		}
		return []string{airport.IataFaa}
	}
	if airport.IataFaa == "" {
		return []string{airport.Icao}
	}
	if airport.Icao == "" {
		return []string{airport.IataFaa}
	}
	return []string{airport.IataFaa, airport.Icao}
}

// Codes returns the airline codes.
func (airline *Airline) Codes() []string {
	if airline.Iata == airline.Icao {
		if airline.Iata == "" {
			return []string{}
		}
		return []string{airline.Iata}
	}
	if airline.Iata == "" {
		return []string{airline.Icao}
	}
	if airline.Icao == "" {
		return []string{airline.Iata}
	}
	return []string{airline.Iata, airline.Icao}
}

// PrettyPrintGetMilesResponse prints a GetMilesResponse in readable format.
func PrettyPrintGetMilesResponse(w io.Writer, response *GetMilesResponse) error {
	for _, segment := range response.Segment {
		fmt.Fprintf(w, "%s-%s %dmi", strings.ToUpper(segment.SourceAirportId), strings.ToUpper(segment.DestinationAirportId), segment.Miles)
		if segment.Miles != segment.ActualMiles {
			fmt.Fprintf(w, " (%dmi actual)", segment.ActualMiles)
		}
		fmt.Fprintln(w)
	}
	fmt.Fprintln(w)
	fmt.Fprintf(w, "%dmi", response.TotalMiles)
	if response.TotalMiles != response.TotalActualMiles {
		fmt.Fprintf(w, " (%dmi actual)", response.TotalActualMiles)
	}
	fmt.Fprintln(w)
	return nil
}
