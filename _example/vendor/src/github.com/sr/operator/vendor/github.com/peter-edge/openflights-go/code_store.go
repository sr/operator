package openflights

import (
	"fmt"
	"strings"
	"unsafe"

	"go.pedge.io/lion/proto"
)

func newCodeStore(idStore *IDStore, options CodeStoreOptions) (*CodeStore, error) {
	codeToAirport, err := getAirportMap(idStore, options)
	if err != nil {
		return nil, err
	}
	codeToAirline, err := getAirlineMap(idStore, options)
	if err != nil {
		return nil, err
	}
	airlineToRoutes, sourceAirportToRoutes, destinationAirportToRoutes, err := getRoutesMaps(idStore, options)
	if err != nil {
		return nil, err
	}
	return &CodeStore{
		codeToAirport,
		codeToAirline,
		airlineToRoutes,
		sourceAirportToRoutes,
		destinationAirportToRoutes,
	}, nil
}

// GetAirportByCode returns the Airport for the given ICAO/IATA/FAA code, or error if it does not exist.
func (c *CodeStore) GetAirportByCode(code string) (*Airport, error) {
	return getAirportByKey(c.CodeToAirport, code)
}

// GetAirlineByCode returns the Airline for the given ICAO/IATA/FAA code, or error if it does not exist.
func (c *CodeStore) GetAirlineByCode(code string) (*Airline, error) {
	return getAirlineByKey(c.CodeToAirline, code)
}

// GetRoutes returns the Routes for the given ICAO/IATA/FAA codes or ids.
func (c *CodeStore) GetRoutes(airline string, source string, dest string) ([]*Route, error) {
	var airlineRoutes []*Route
	var sourceAirportRoutes []*Route
	var destinationAirportRoutes []*Route
	if airline != "" {
		airlineRoutes = c.AirlineToRoutes[strings.ToLower(airline)]
	}
	if source != "" {
		sourceAirportRoutes = c.SourceAirportToRoutes[strings.ToLower(source)]
	}
	if dest != "" {
		destinationAirportRoutes = c.DestinationAirportToRoutes[strings.ToLower(dest)]
	}
	return routesIntersection(airlineRoutes, sourceAirportRoutes, destinationAirportRoutes), nil
}

func getAirportMap(idStore *IDStore, options CodeStoreOptions) (map[string]*Airport, error) {
	m := make(map[string]*Airport)
	for _, airport := range idStore.IdToAirport {
		if !options.NoFilterDuplicates {
			include, err := includeAirport(airport)
			if err != nil {
				return nil, err
			}
			if !include {
				continue
			}
		}
		for _, s := range airport.Codes() {
			if _, ok := m[strings.ToLower(s)]; ok {
				err := fmt.Errorf("openflights: duplicate airport key: %s", s)
				if options.NoFilterDuplicates || options.NoErrorOnDuplicates {
					protolion.Warnln(err.Error())
				} else {
					return nil, err
				}
			}
			m[strings.ToLower(s)] = airport
		}
	}
	return m, nil
}

func getAirlineMap(idStore *IDStore, options CodeStoreOptions) (map[string]*Airline, error) {
	airlineCodeToAirlineIDToNumRoutes := getAirlineCodeToAirlineIDToNumRoutes(idStore.Route)
	m := make(map[string]*Airline)
	for _, airline := range idStore.IdToAirline {
		if !options.NoFilterDuplicates {
			include, err := includeAirline(airline, airlineCodeToAirlineIDToNumRoutes)
			if err != nil {
				return nil, err
			}
			if !include {
				continue
			}
		}
		for _, s := range airline.Codes() {
			if _, ok := m[strings.ToLower(s)]; ok {
				err := fmt.Errorf("openflights: duplicate airline key: %s", s)
				if options.NoFilterDuplicates || options.NoErrorOnDuplicates {
					protolion.Warnln(err.Error())
				} else {
					return nil, err
				}
			}
			m[strings.ToLower(s)] = airline
		}
	}
	return m, nil
}

func getRoutesMaps(idStore *IDStore, options CodeStoreOptions) (map[string][]*Route, map[string][]*Route, map[string][]*Route, error) {
	airlineMap := make(map[string][]*Route)
	sourceAirportMap := make(map[string][]*Route)
	destinationAirportMap := make(map[string][]*Route)
	for _, route := range idStore.Route {
		if !options.NoFilterDuplicates {
			include, err := includeRoute(route)
			if err != nil {
				return nil, nil, nil, err
			}
			if !include {
				continue
			}
		}
		for _, airline := range append(route.Airline.Codes(), route.Airline.Id) {
			airline = strings.ToLower(airline)
			if _, ok := airlineMap[airline]; !ok {
				airlineMap[airline] = make([]*Route, 0)
			}
			if !containsRoute(airlineMap[airline], route) {
				airlineMap[airline] = append(airlineMap[airline], route)
			}
		}
		for _, source := range append(route.SourceAirport.Codes(), route.SourceAirport.Id) {
			source = strings.ToLower(source)
			if _, ok := sourceAirportMap[source]; !ok {
				sourceAirportMap[source] = make([]*Route, 0)
			}
			if !containsRoute(sourceAirportMap[source], route) {
				sourceAirportMap[source] = append(sourceAirportMap[source], route)
			}
		}
		for _, dest := range append(route.DestinationAirport.Codes(), route.DestinationAirport.Id) {
			dest = strings.ToLower(dest)
			if _, ok := destinationAirportMap[dest]; !ok {
				destinationAirportMap[dest] = make([]*Route, 0)
			}
			if !containsRoute(destinationAirportMap[dest], route) {
				destinationAirportMap[dest] = append(destinationAirportMap[dest], route)
			}
		}
	}
	return airlineMap, sourceAirportMap, destinationAirportMap, nil
}

// yaaaaaaaaaaaaaa
func routesIntersection(routesSlices ...[]*Route) []*Route {
	var filtered [][]*Route
	for _, routes := range routesSlices {
		if len(routes) > 0 {
			filtered = append(filtered, routes)
		}
	}
	if len(filtered) == 0 {
		return nil
	}
	if len(filtered) == 1 {
		return filtered[0]
	}
	maps := make([]map[uintptr]bool, len(filtered))
	for i, routes := range filtered {
		m := make(map[uintptr]bool)
		for _, route := range routes {
			m[uintptr(unsafe.Pointer(route))] = true
		}
		maps[i] = m
	}
	intersect := maps[0]
	for i := 1; i < len(maps); i++ {
		check := maps[i]
		for key := range intersect {
			if _, ok := check[key]; !ok {
				delete(intersect, key)
			}
		}
		if len(intersect) == 0 {
			return nil
		}
	}
	ret := make([]*Route, len(intersect))
	i := 0
	for ptr := range intersect {
		ret[i] = (*Route)(unsafe.Pointer(ptr))
		i++
	}
	return ret
}
