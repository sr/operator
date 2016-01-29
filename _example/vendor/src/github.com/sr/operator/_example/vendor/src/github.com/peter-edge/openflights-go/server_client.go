package openflights

import (
	"fmt"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
)

type serverClient struct {
	*IDStore
	*CodeStore
}

func newServerClient(idStore *IDStore, codeStore *CodeStore) (*serverClient, error) {
	return &serverClient{
		idStore,
		codeStore,
	}, nil
}

func (s *serverClient) GetAirport(idOrCode string) (*Airport, error) {
	airport, err := s.GetAirportByCode(idOrCode)
	if err != nil && grpc.Code(err) == codes.NotFound {
		return s.GetAirportByID(idOrCode)
	}
	return airport, err
}

func (s *serverClient) GetAirline(idOrCode string) (*Airline, error) {
	airline, err := s.GetAirlineByCode(idOrCode)
	if err != nil && grpc.Code(err) == codes.NotFound {
		return s.GetAirlineByID(idOrCode)
	}
	return airline, err
}

func (s *serverClient) GetDistance(sourceAirportIDOrCode string, destinationAirportIDOrCode string) (uint32, error) {
	sourceAirport, err := s.GetAirport(sourceAirportIDOrCode)
	if err != nil {
		return 0, err
	}
	destinationAirport, err := s.GetAirport(destinationAirportIDOrCode)
	if err != nil {
		return 0, err
	}
	return getDistanceForAirports(sourceAirport, destinationAirport), nil
}

func (s *serverClient) GetMiles(request *GetMilesRequest) (*GetMilesResponse, error) {
	segments, err := getSegmentsWithoutMiles(request.Route)
	if err != nil {
		return nil, err
	}
	multiplier := float64(request.Percentage) / 100.0
	if multiplier == 0 {
		multiplier = 1.0
	}
	minMiles := uint32(float64(request.MinMiles) * multiplier)
	for _, segment := range segments {
		actualMiles, err := s.GetDistance(segment.SourceAirportId, segment.DestinationAirportId)
		if err != nil {
			return nil, err
		}
		miles := uint32(float64(actualMiles) * multiplier)
		if minMiles != 0 && miles < minMiles {
			miles = minMiles
		}
		segment.ActualMiles = actualMiles
		segment.Miles = miles
	}
	var totalActualMiles uint32
	var totalMiles uint32
	for _, segment := range segments {
		totalActualMiles += segment.ActualMiles
		totalMiles += segment.Miles
	}
	return &GetMilesResponse{
		Segment:          segments,
		TotalMiles:       totalMiles,
		TotalActualMiles: totalActualMiles,
	}, nil
}

func getSegmentsWithoutMiles(route string) ([]*GetMilesResponse_Segment, error) {
	var segmentStrings []string
	for _, segmentString := range strings.Split(route, "/") {
		segmentString = strings.TrimSpace(segmentString)
		if len(segmentString) != 0 {
			segmentStrings = append(segmentStrings, segmentString)
		}
	}
	var segments [][]string
	for _, segmentString := range segmentStrings {
		var segment []string
		for _, s := range strings.Split(segmentString, "-") {
			for _, t := range strings.Split(s, " ") {
				u := strings.TrimSpace(t)
				if len(u) > 0 {
					segment = append(segment, u)
				}
			}
		}
		if len(segment) < 2 {
			return nil, fmt.Errorf("openflights: invalid route: %s", route)
		}
		segments = append(segments, segment)
	}
	var protoSegments []*GetMilesResponse_Segment
	for _, segment := range segments {
		for i := 0; i < len(segment)-1; i++ {
			protoSegments = append(
				protoSegments,
				&GetMilesResponse_Segment{
					SourceAirportId:      segment[i],
					DestinationAirportId: segment[i+1],
				},
			)
		}
	}
	return protoSegments, nil
}
