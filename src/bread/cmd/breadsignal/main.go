// Command breadsignal sends a message to the BREAD chat room.
package main

import (
	"bread"
	"errors"
	"flag"
	"fmt"
	"os"

	"golang.org/x/net/context"

	"github.com/sr/operator/hipchat"
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
	token, ok := os.LookupEnv("HIPCHAT_TOKEN")
	if !ok {
		return errors.New("required environment variable missing: HIPCHAT_TOKEN")
	}
	client, err := bread.NewHipchatClient(&operatorhipchat.ClientConfig{
		Hostname: bread.HipchatHost,
		Token:    token,
	})
	if err != nil {
		return err
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
	return client.SendRoomNotification(
		context.Background(),
		&operatorhipchat.RoomNotification{
			MessageOptions: &operatorhipchat.MessageOptions{
				Color: color,
				From:  "breadsignal",
			},
			Message:       message,
			MessageFormat: "html",
			RoomID:        int64(room),
		},
	)
}
