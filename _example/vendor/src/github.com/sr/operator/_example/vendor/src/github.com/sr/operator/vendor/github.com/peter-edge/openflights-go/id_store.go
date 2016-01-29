package openflights

import (
	"bytes"
	"encoding/csv"
	"fmt"
	"strings"

	"golang.org/x/net/context"
)

func newIDStore(csvStore *CSVStore) (*IDStore, error) {
	idToAirport, err := getIDToAirport(csvStore.Airports)
	if err != nil {
		return nil, err
	}
	idToAirline, err := getIDToAirline(csvStore.Airlines)
	if err != nil {
		return nil, err
	}
	routes, err := getRoutes(csvStore.Routes, idToAirport, idToAirline)
	if err != nil {
		return nil, err
	}
	return &IDStore{
		idToAirport,
		idToAirline,
		routes,
	}, nil
}

// GetAllAirports returns all Airports.
func (i *IDStore) GetAllAirports() (<-chan *Airport, chan<- bool, <-chan error, error) {
	out := make(chan *Airport)
	cancel := make(chan bool, 1)
	callbackErr := make(chan error, 1)
	go func() {
		defer close(out)
		defer close(callbackErr)
		for _, airport := range i.IdToAirport {
			select {
			case out <- airport:
			case <-cancel:
				// I don't particularly like the context.Canceled error, but we do this to
				// be consistent with other Go libraries.
				callbackErr <- context.Canceled
				return
			}
		}
		callbackErr <- nil
	}()
	return out, cancel, callbackErr, nil
}

// GetAllAirlines returns all Airlines.
func (i *IDStore) GetAllAirlines() (<-chan *Airline, chan<- bool, <-chan error, error) {
	out := make(chan *Airline)
	cancel := make(chan bool, 1)
	callbackErr := make(chan error, 1)
	go func() {
		defer close(out)
		defer close(callbackErr)
		for _, airline := range i.IdToAirline {
			select {
			case out <- airline:
			case <-cancel:
				callbackErr <- context.Canceled
				return
			}
		}
		callbackErr <- nil
	}()
	return out, cancel, callbackErr, nil
}

// GetAllRoutes returns all Routes.
func (i *IDStore) GetAllRoutes() (<-chan *Route, chan<- bool, <-chan error, error) {
	out := make(chan *Route)
	cancel := make(chan bool, 1)
	callbackErr := make(chan error, 1)
	go func() {
		defer close(out)
		defer close(callbackErr)
		for _, route := range i.Route {
			select {
			case out <- route:
			case <-cancel:
				callbackErr <- context.Canceled
				return
			}
		}
		callbackErr <- nil
	}()
	return out, cancel, callbackErr, nil
}

// GetAirportByID returns an Airport by ID, or error if it does not exist.
func (i *IDStore) GetAirportByID(id string) (*Airport, error) {
	return getAirportByKey(i.IdToAirport, id)
}

// GetAirlineByID returns an Airline by ID, or error if it does not exist.
func (i *IDStore) GetAirlineByID(id string) (*Airline, error) {
	return getAirlineByKey(i.IdToAirline, id)
}

func getIDToAirport(data []byte) (map[string]*Airport, error) {
	records, err := getOpenFlightsRecords(data)
	if err != nil {
		return nil, err
	}
	return getIDToAirportForRecords(records)
}

func getIDToAirline(data []byte) (map[string]*Airline, error) {
	records, err := getOpenFlightsRecords(data)
	if err != nil {
		return nil, err
	}
	return getIDToAirlineForRecords(records)
}

func getRoutes(data []byte, idToAirport map[string]*Airport, idToAirline map[string]*Airline) ([]*Route, error) {
	records, err := getOpenFlightsRecords(data)
	if err != nil {
		return nil, err
	}
	return getRoutesForRecords(records, idToAirport, idToAirline)
}

func getIDToAirportForRecords(records [][]string) (map[string]*Airport, error) {
	idToAirport := make(map[string]*Airport, len(records))
	for _, record := range records {
		airport, err := getAirportForRecord(record)
		if err != nil {
			return nil, err
		}
		idToAirport[airport.Id] = airport
	}
	return idToAirport, nil
}

func getIDToAirlineForRecords(records [][]string) (map[string]*Airline, error) {
	idToAirline := make(map[string]*Airline, len(records))
	for _, record := range records {
		airline, err := getAirlineForRecord(record)
		if err != nil {
			return nil, err
		}
		// TODO(pedge): manual filter
		if airline.Id != "-1" {
			idToAirline[airline.Id] = airline
		}
	}
	return idToAirline, nil
}

func getRoutesForRecords(records [][]string, idToAirport map[string]*Airport, idToAirline map[string]*Airline) ([]*Route, error) {
	var routes []*Route
	for _, record := range records {
		route, err := getRouteForRecord(record, idToAirport, idToAirline)
		if err != nil {
			return nil, err
		}
		if route != nil {
			routes = append(routes, route)
		}
	}
	return routes, nil
}

func getAirportForRecord(record []string) (*Airport, error) {
	latitudeMicros, err := parseFloat(record[6], 1000000)
	if err != nil {
		return nil, err
	}
	longitudeMicros, err := parseFloat(record[7], 1000000)
	if err != nil {
		return nil, err
	}
	altitudeFeet, err := parseInt(record[8])
	if err != nil {
		return nil, err
	}
	timezoneOffsetMinutes, err := parseFloat(record[9], 60)
	if err != nil {
		return nil, err
	}
	dstValue, ok := DST_value[fmt.Sprintf("DST_%s", record[10])]
	if !ok {
		return nil, fmt.Errorf("openflights: no DST value for '%s' in %v", record[10], record)
	}
	return &Airport{
		Id:                    record[0],
		Name:                  record[1],
		City:                  record[2],
		Country:               record[3],
		IataFaa:               record[4],
		Icao:                  record[5],
		LatitudeMicros:        int32(latitudeMicros),
		LongitudeMicros:       int32(longitudeMicros),
		AltitudeFeet:          uint32(altitudeFeet),
		TimezoneOffsetMinutes: int32(timezoneOffsetMinutes),
		Dst:      DST(dstValue),
		Timezone: record[11],
	}, nil
}

func getAirlineForRecord(record []string) (*Airline, error) {
	active, err := getOpenFlightsBool(record[7], record)
	if err != nil {
		return nil, err
	}
	return &Airline{
		Id:       record[0],
		Name:     record[1],
		Alias:    record[2],
		Iata:     record[3],
		Icao:     record[4],
		Callsign: record[5],
		Country:  record[6],
		Active:   active,
	}, nil
}

func getRouteForRecord(record []string, idToAirport map[string]*Airport, idToAirline map[string]*Airline) (*Route, error) {
	if record[1] == "" || record[3] == "" || record[5] == "" {
		return nil, nil
	}
	airline, ok := idToAirline[record[1]]
	if !ok {
		return nil, fmt.Errorf("openflights: no airline for id '%s' in %v", record[1], record)
	}
	sourceAirport, ok := idToAirport[record[3]]
	if !ok {
		return nil, fmt.Errorf("openflights: no airport for id '%s' in %v", record[3], record)
	}
	destinationAirport, ok := idToAirport[record[5]]
	if !ok {
		return nil, fmt.Errorf("openflights: no airport for id '%s' in %v", record[5], record)
	}
	codeshare, err := getOpenFlightsBool(record[6], record)
	if err != nil {
		return nil, err
	}
	stops, err := parseInt(record[7])
	if err != nil {
		return nil, err
	}
	return &Route{
		Airline:            airline,
		SourceAirport:      sourceAirport,
		DestinationAirport: destinationAirport,
		Codeshare:          codeshare,
		Stops:              uint32(stops),
	}, nil
}

func getOpenFlightsRecords(data []byte) (_ [][]string, retErr error) {
	records, err := csv.NewReader(bytes.NewReader(data)).ReadAll()
	if err != nil {
		return nil, err
	}
	return cleanOpenFlightsRecords(records), nil
}

func getOpenFlightsBool(s string, record []string) (bool, error) {
	if s == "" {
		// TODO(pedge): should we have an unknown value?
		return false, nil
	}
	switch strings.ToLower(s) {
	case "y":
		return true, nil
	case "n":
		return false, nil
	default:
		return false, fmt.Errorf("openflights: unknown bool value '%s' in %v", s, record)
	}
}

func cleanOpenFlightsRecords(records [][]string) [][]string {
	for _, record := range records {
		for i, column := range record {
			if column == "\\N" {
				record[i] = ""
			}
		}
	}
	return records
}
