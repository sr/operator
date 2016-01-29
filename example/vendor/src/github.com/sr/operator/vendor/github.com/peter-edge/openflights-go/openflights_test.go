package openflights

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestGetAirport(t *testing.T) {
	t.Parallel()
	client := getTestClient(t)
	for _, s := range []string{"VIE", "vie", "Vie"} {
		vie, err := client.GetAirport(s)
		require.NoError(t, err)
		require.Equal(
			t,
			&Airport{
				Id:                    "1613",
				Name:                  "Schwechat",
				City:                  "Vienna",
				Country:               "Austria",
				IataFaa:               "VIE",
				Icao:                  "LOWW",
				LatitudeMicros:        48110278,
				LongitudeMicros:       16569722,
				AltitudeFeet:          600,
				TimezoneOffsetMinutes: 60,
				Dst:      DST_DST_E,
				Timezone: "Europe/Vienna",
			},
			vie,
		)
	}
}

func TestGetRoutes(t *testing.T) {
	t.Parallel()
	client := getTestClient(t)
	for _, code := range []string{"LH", "DLH", "lh", "dlh"} {
		routes, err := client.GetRoutes(code, "SFO", "MUC")
		require.NoError(t, err)
		dlh, err := client.GetAirline("DLH")
		require.NoError(t, err)
		sfo, err := client.GetAirport("SFO")
		require.NoError(t, err)
		muc, err := client.GetAirport("MUC")
		require.NoError(t, err)
		expected := []*Route{
			{
				Airline:            dlh,
				SourceAirport:      sfo,
				DestinationAirport: muc,
				Codeshare:          false,
				Stops:              0,
			},
		}
		require.Equal(t, len(expected), len(routes))
		for i, route := range routes {
			require.Equal(t, expected[i], route)
		}
	}
}

func TestGetDistance(t *testing.T) {
	t.Parallel()
	client := getTestClient(t)
	for _, s := range []string{"SFO", "sfo", "Sfo"} {
		for _, s2 := range []string{"FRA", "fra", "Fra"} {
			distanceMiles, err := client.GetDistance(s, s2)
			require.NoError(t, err)
			require.Equal(t, uint32(5684), distanceMiles)
		}
	}
}

func TestGetAllAirports(t *testing.T) {
	//t.Parallel()
	client := getTestClient(t)
	out, _, callbackErr, err := client.GetAllAirports()
	require.NoError(t, err)
	ids := make(map[string]bool)
	for airport := range out {
		_, ok := ids[airport.Id]
		require.False(t, ok)
		ids[airport.Id] = true
	}
	require.Nil(t, <-callbackErr)
	require.Equal(t, 8107, len(ids))
}

func TestGetMiles(t *testing.T) {
	t.Parallel()
	client := getTestClient(t)
	testGetMiles(t, client, "vie-jfk", 0, 0, 1, 4228, 4228)
	testGetMiles(t, client, "vie jfk", 0, 0, 1, 4228, 4228)
	testGetMiles(t, client, "vie  jfk", 0, 0, 1, 4228, 4228)
	testGetMiles(t, client, "vie - jfk", 0, 0, 1, 4228, 4228)
	testGetMiles(t, client, "vie-ord-mem", 0, 0, 2, 5193, 5193)
	testGetMiles(t, client, "vie ord mem", 0, 0, 2, 5193, 5193)
	testGetMiles(t, client, "vie ord  mem", 0, 0, 2, 5193, 5193)
	testGetMiles(t, client, "vie ord  mem", 0, 100, 2, 5193, 5193)
	testGetMiles(t, client, "vie ord mem", 493, 0, 2, 5194, 5193)
	testGetMiles(t, client, "vie ord mem", 493, 150, 2, 7790, 5193)
	testGetMiles(t, client, "vie ord mem/jfk vie / vie - bru - ord - iad", 500, 0, 6, 14738, 14730)
	testGetMiles(t, client, "vie ord mem/jfk vie / vie - bru - ord - iad", 500, 150, 6, 22106, 14730)
}

func testGetMiles(t *testing.T, client Client, route string, minMiles uint32, percentage uint32, expectedNumSegments int, expectedTotalMiles uint32, expectedTotalActualMiles uint32) {
	response, err := client.GetMiles(
		&GetMilesRequest{
			Route:      route,
			MinMiles:   minMiles,
			Percentage: percentage,
		},
	)
	require.NoError(t, err)
	require.Equal(t, expectedNumSegments, len(response.Segment))
	require.Equal(t, int(expectedTotalMiles), int(response.TotalMiles))
	require.Equal(t, int(expectedTotalActualMiles), int(response.TotalActualMiles))
}

func getTestClient(t *testing.T) Client {
	idStore, err := NewIDStore(_GlobalCSVStore)
	require.NoError(t, err)
	serverClient, err := NewServerClient(idStore, CodeStoreOptions{})
	require.NoError(t, err)
	// normally in Go code you would directly call the Client,
	// but for testing I want to go through the whole chain.
	return NewClient(NewLocalAPIClient(NewAPIServer(serverClient)))
}
