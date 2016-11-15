package main

import (
	"encoding/csv"
	"errors"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"

	"github.com/google/go-github/github"
)

const (
	defaultGithubURL = "https://git.dev.pardot.com"
)

var (
	apply           bool
	githubURL       string
	username        string
	token           string
	dormantUsersCsv string
)

func run() error {
	flag.BoolVar(&apply, "apply", false, "Suspend users for real")
	flag.StringVar(&githubURL, "github-url", defaultGithubURL, "URL of the GitHub Enterprise installation")
	flag.StringVar(&username, "username", "", "Username of a GitHub Enterprise administrator")
	flag.StringVar(&token, "token", "", "Personal Access Token of a GitHub Enterprise administrator")
	flag.StringVar(&dormantUsersCsv, "dormant-users-csv", "", "CSV file of dormant users. Download from https://git.dev.pardot.com/stafftools/reports/dormant_users.csv")
	flag.Parse()
	if username == "" {
		return errors.New("required flag missing: username")
	}
	if token == "" {
		return errors.New("required flag missing: token")
	}
	if dormantUsersCsv == "" {
		return errors.New("required flag missing: dormant-users-csv")
	}

	csvFile, err := os.Open(dormantUsersCsv)
	if err != nil {
		return err
	}
	defer func() { _ = csvFile.Close() }()

	csvReader := csv.NewReader(csvFile)
	firstRow := true
	suspendableUsernames := []string{}
	for {
		record, err := csvReader.Read()
		if err == io.EOF {
			break
		} else if err != nil {
			return err
		}

		if firstRow {
			firstRow = false
			continue
		}

		username := record[2]
		if !strings.HasPrefix(username, "sa-") {
			suspendableUsernames = append(suspendableUsernames, username)
		}
	}

	transport := github.BasicAuthTransport{Username: username, Password: token}
	client := transport.Client()
	for _, username := range suspendableUsernames {
		if apply {
			fmt.Printf("Suspending user '%s'\n", username)

			req, err := http.NewRequest("PUT", githubURL+"/api/v3/users/"+username+"/suspended", nil)
			if err != nil {
				return err
			}

			resp, err := client.Do(req)
			if err != nil {
				return err
			}
			_ = resp.Body.Close()

			if resp.StatusCode < 200 || resp.StatusCode > 299 {
				return fmt.Errorf("error suspending '%s': HTTP %d", username, resp.StatusCode)
			}
		} else {
			fmt.Printf("Would suspend user '%s'\n", username)
		}
	}

	return nil
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "githubsuspender: %v\n", err)
		os.Exit(1)
	}
	os.Exit(0)
}
