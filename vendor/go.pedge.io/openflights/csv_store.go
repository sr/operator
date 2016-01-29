package openflights

import (
	"fmt"
	"io/ioutil"
	"net/http"
)

func getCSVStore() (*CSVStore, error) {
	airports, err := getOpenFlightsData("airports.dat")
	if err != nil {
		return nil, err
	}
	airlines, err := getOpenFlightsData("airlines.dat")
	if err != nil {
		return nil, err
	}
	routes, err := getOpenFlightsData("routes.dat")
	if err != nil {
		return nil, err
	}
	return &CSVStore{
		airports,
		airlines,
		routes,
	}, nil
}

func getOpenFlightsData(file string) (_ []byte, retErr error) {
	response, err := http.Get(fmt.Sprintf("https://raw.githubusercontent.com/jpatokal/openflights/master/data/%s", file))
	if err != nil {
		return nil, err
	}
	defer func() {
		if err := response.Body.Close(); err != nil && retErr == nil {
			retErr = err
		}
	}()
	return ioutil.ReadAll(response.Body)
}
