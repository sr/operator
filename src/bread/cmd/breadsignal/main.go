// Command breadsignal sends a message to the BREAD chat room.
package main

import (
	"bread"
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"net/http"
	"os"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "breadsignal: %v\n", err)
		os.Exit(1)
	}
	os.Exit(0)
}

func run() error {
	terraformAction := flag.String("terraform", "", "Notify the BREAD team of a terraform actions (either plan or apply)")
	terraformVersion := flag.String("terraform-version", "", "Installed terraform version")
	terraformPath := flag.String("terraform-path", "", "the path being acted upon")
	gitBranch := flag.String("branch", "unknown", "Checked out BREAD repo branch")
	testing := flag.Bool("testing", true, "Send all notifications to the BREAD Testing room when true")
	flag.Parse()
	if *terraformAction == "" {
		return nil
	}
	if *terraformVersion == "" {
		return errors.New("required flag missing: terraform-version")
	}
	hipchatToken, ok := os.LookupEnv("HIPCHAT_TOKEN")
	if !ok {
		return errors.New("required environment variable missing: HIPCHAT_TOKEN")
	}
	var (
		color   string
		message string
		room    int
	)
	if *testing {
		room = bread.TestingRoom
	} else {
		room = bread.PublicRoom
	}
	switch *terraformAction {
	case "plan":
		color = "gray"
		message = fmt.Sprintf(
			"planning terraform changes on branch <code>%s</code> with <code>%s</code> to terraform path <code>%s</code>",
			*gitBranch,
			*terraformVersion,
			*terraformPath,
		)
	case "apply":
		color = "yellow"
		message = fmt.Sprintf(
			"deploying terraform branch <code>%s</code> with <code>%s</code> to terraform path <code>%s</code>",
			*gitBranch,
			*terraformVersion,
			*terraformPath,
		)
	case "push":
		color = "red"
		message = fmt.Sprintf(
			"pushing terraform remote configuration from branch <code>%s</code> with <code>%s</code> to terraform path <code>%s</code>",
			*gitBranch,
			*terraformVersion,
			*terraformPath,
		)
	default:
		return nil
	}
	input := struct {
		Color         string `json:"color"`
		From          string `json:"from"`
		Message       string `json:"message"`
		MessageFormat string `json:"message_format"`
	}{
		color,
		"breadsignal",
		message,
		"html",
	}
	data, err := json.Marshal(input)
	if err != nil {
		return err
	}
	client := &http.Client{}
	req, err := http.NewRequest(
		"POST",
		fmt.Sprintf(
			"%s/v2/room/%d/notification",
			bread.HipchatHost,
			room,
		),
		bytes.NewReader(data),
	)
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+hipchatToken)
	req.Header.Set("Content-Type", "application/json")
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("hipchat request failed: %v", err)
	}
	if resp.StatusCode != 204 {
		return fmt.Errorf("hipchat request failed with status %d", resp.StatusCode)
	}
	return err
}
