package main

import (
	"devenv"
	"fmt"
	"io"
	"log"
	"log/syslog"
	"os"
	"strings"
	"syscall"
	"time"

	"github.com/fsouza/go-dockerclient"

	"golang.org/x/net/context"
)

const (
	DockerBinary  = "/usr/local/bin/docker"
	ComposeBinary = "/usr/local/bin/docker-compose"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "devenv: %v\n", err)
		os.Exit(1)
	}
	os.Exit(0)
}

func run() error {
	logger := buildLogger()

	args := os.Args[1:]
	if len(args) <= 0 || args[0] == "--help" || args[0] == "-h" {
		usage()
	} else if args[0] == "version" {
		fmt.Printf("%s\n", devenv.Version)
	} else if args[0] == "docker" || args[0] == "compose" {
		errors := devenv.UnsatisfiedRequirements()
		if len(errors) > 0 {
			fmt.Fprintf(os.Stderr, "devenv cannot start until the following requirements are satisfied:\n")
			for e := range errors {
				fmt.Fprintf(os.Stderr, "  * %v\n", e)
			}
			return fmt.Errorf("unresolved requirements")
		}

		client, err := docker.NewClientFromEnv()
		if err != nil {
			return err
		}

		forwarder := devenv.NewSSHForwarder(client, logger)
		if forwarder.IsStarted() {
			authSock, err := forwarder.DockerSSHAuthSock()
			if err != nil {
				fmt.Fprintf(os.Stderr, "Warning: Unable to setup SSH auth socket. This might mean the ssh-forwarder service didn't start properly. The error was: %v\n", err)
				return err
			}
			if err := os.Setenv("DOCKER_SSH_AUTH_SOCK", authSock); err != nil {
				return err
			}

			volume, err := forwarder.DockerVolume()
			if err != nil {
				fmt.Fprintf(os.Stderr, "Warning: Unable to setup SSH auth socket. This might mean the ssh-forwarder service didn't start properly. The error was: %v\n", err)
			}
			if err := os.Setenv("DOCKER_SSH_AUTH_VOLUME", volume); err != nil {
				return err
			}
		} else {
			fmt.Fprintf(os.Stderr, "Warning: The ssh-forwarder container is not started. Have you started the service? Try: brew services start devenv\n")
		}

		if args[0] == "docker" {
			if args[1] == "run" {
				newArgs := args[0:2]
				newArgs = append(newArgs, "-e", "DOCKER_SSH_AUTH_SOCK", "-v", os.Getenv("DOCKER_SSH_AUTH_VOLUME"))
				newArgs = append(newArgs, args[2:]...)
				args = newArgs
			}

			if err := syscall.Exec(DockerBinary, args, os.Environ()); err != nil {
				return err
			}
		} else if args[0] == "compose" {
			// If left unspecified by the user, set COMPOSE_FILE to include
			// docker-compose.dev.yml
			if os.Getenv("COMPOSE_FILE") == "" {
				cwd, err := os.Getwd()
				if err != nil {
					return err
				}

				composeFiles := make([]string, 0, 2)
				if file := devenv.FindDockerComposeFile("docker-compose.yml", cwd); file != "" {
					composeFiles = append(composeFiles, file)
				}
				if file := devenv.FindDockerComposeFile("docker-compose.dev.yml", cwd); file != "" {
					composeFiles = append(composeFiles, file)
				}
				if err = os.Setenv("COMPOSE_FILE", strings.Join(composeFiles, ":")); err != nil {
					return err
				}
			}

			if err := syscall.Exec(ComposeBinary, args, os.Environ()); err != nil {
				return err
			}
		}
	} else if args[0] == "ssh-forwarder" {
		client, err := docker.NewClientFromEnv()
		if err != nil {
			return err
		}

		// TODO: Make timeout configurable
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		defer cancel()

		forwarder := devenv.NewSSHForwarder(client, logger)
		if err := forwarder.Run(ctx); err != nil {
			logger.Printf("ssh-forwarder: %v\n", err)
			return err
		}
	} else {
		usage()
		return fmt.Errorf("unknown command: %v", args[0])
	}
	return nil
}

func usage() {
	fmt.Println("Usage: devenv COMMAND [arg...]")
	fmt.Println("       devenv [--help]")
	fmt.Println("")
	fmt.Println("A developer-friendly wrapper for Docker")
	fmt.Println("")
	fmt.Println("Commands:")
	fmt.Println("  version Displays the installed version of `devenv`")
	fmt.Println("  docker  Sets up a Docker environment and executes `docker`")
	fmt.Println("  compose Sets up a Docker environment and executes `docker-compose`")
	fmt.Println("")
	fmt.Println("Examples:")
	fmt.Println("  devenv docker ps")
	fmt.Println("  devenv compose up")
	fmt.Println("")
}

func buildLogger() *log.Logger {
	var w io.Writer

	w, err := syslog.New(syslog.LOG_NOTICE|syslog.LOG_DAEMON, "devenv")
	if err != nil {
		return log.New(os.Stderr, "devenv", log.LstdFlags)
	}

	return log.New(w, "", 0)
}
