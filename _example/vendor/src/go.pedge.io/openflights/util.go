package openflights

import (
	"math"
	"strconv"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
)

func getAirportByKey(m map[string]*Airport, key string) (*Airport, error) {
	airport, ok := m[strings.ToLower(key)]
	if !ok {
		return nil, grpc.Errorf(codes.NotFound, key)
	}
	return airport, nil
}

func getAirlineByKey(m map[string]*Airline, key string) (*Airline, error) {
	airline, ok := m[strings.ToLower(key)]
	if !ok {
		return nil, grpc.Errorf(codes.NotFound, key)
	}
	return airline, nil
}

func getRouteByKey(m map[string]*Route, key string) (*Route, error) {
	route, ok := m[strings.ToLower(key)]
	if !ok {
		return nil, grpc.Errorf(codes.NotFound, key)
	}
	return route, nil
}

func getRoutesByKeys(m map[string]map[string]map[string][]*Route, airline string, source string, dest string) ([]*Route, error) {
	n, ok := m[strings.ToLower(airline)]
	if !ok {
		return nil, grpc.Errorf(codes.NotFound, airline)
	}
	o, ok := n[strings.ToLower(source)]
	if !ok {
		return nil, grpc.Errorf(codes.NotFound, source)
	}
	routes, ok := o[strings.ToLower(dest)]
	if !ok {
		return nil, grpc.Errorf(codes.NotFound, dest)
	}
	return routes, nil
}

func getDistanceForAirports(airport1 *Airport, airport2 *Airport) uint32 {
	return getDistance(
		float64(airport1.LatitudeMicros)/1000000,
		float64(airport1.LongitudeMicros)/1000000,
		float64(airport2.LatitudeMicros)/1000000,
		float64(airport2.LongitudeMicros)/1000000,
	)
}

func getDistance(lat1 float64, lng1 float64, lat2 float64, lng2 float64) uint32 {
	dLat := (lat2 - lat1) * (math.Pi / 180.0)
	dLon := (lng2 - lng1) * (math.Pi / 180.0)
	lat1 = lat1 * (math.Pi / 180.0)
	lat2 = lat2 * (math.Pi / 180.0)
	a1 := math.Sin(dLat/2) * math.Sin(dLat/2)
	a2 := math.Sin(dLon/2) * math.Sin(dLon/2) * math.Cos(lat1) * math.Cos(lat2)
	a := a1 + a2
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	miles := 3959 * c
	return uint32(round(math.Floor(miles)))
}

// expensive
func containsRoute(s []*Route, route *Route) bool {
	for _, check := range s {
		if route == check {
			return true
		}
	}
	return false
}

func containsString(slice []string, s string) bool {
	for _, check := range slice {
		if s == check {
			return true
		}
	}
	return false
}

func parseInt(s string) (int, error) {
	i, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return 0, err
	}
	return int(i), nil
}

func parseFloat(s string, multiplier int) (int, error) {
	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, err
	}
	return round(f * float64(multiplier)), nil
}

func round(num float64) int {
	return int(num + math.Copysign(0.5, num))
}
