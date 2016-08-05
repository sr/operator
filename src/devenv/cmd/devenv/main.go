package main

import (
	"devenv"
	"devenv/sshforwarder"
	"fmt"
	"log"
	"os"
	"os/exec"
	"syscall"
)

func main() {
	args := os.Args[1:]
	if len(args) <= 0 || args[0] == "--help" || args[0] == "-h" {
		usage(0)
	} else if args[0] == "--version" || args[0] == "-v" {
		fmt.Printf("%s\n", devenv.Version)
	} else if args[0] == "docker" || args[0] == "compose" {
		errors := devenv.UnsatisfiedRequirements()
		if len(errors) > 0 {
			printErrorsAndExit(errors)
		}

		if sshforwarder.IsStarted() {
			authSock, err := sshforwarder.DockerSSHAuthSock()
			if err != nil {
				log.Fatalf("error: could not determine docker ssh auth sock for ssh forwarder: %v", err)
			}

			if err = os.Setenv("SSH_AUTH_SOCK", authSock); err != nil {
				log.Fatalf("error: unable to set SSH_AUTH_SOCK environment variable: %v", err)
			}

			volume, err := sshforwarder.DockerVolume()
			if err != nil {
				log.Fatalf("error: could not determine docker volume mount for ssh forwarder: %v", err)
			}

			if err = os.Setenv("SSH_AUTH_VOLUME", volume); err != nil {
				log.Fatalf("error: unable to set SSH_AUTH_VOLUME environment variable: %v", err)
			}
		} else {
			log.Printf("warning: the ssh-forwarder container is not started")
		}

		if args[0] == "docker" {
			if args[1] == "run" {
				newArgs := args[0:2]
				newArgs = append(newArgs, "-e", "SSH_AUTH_SOCK", "-v", os.Getenv("SSH_AUTH_VOLUME"))
				newArgs = append(newArgs, args[2:]...)
				args = newArgs
			}

			dockerPath, err := exec.LookPath("docker")
			if err != nil {
				log.Fatalf("error: unable to find docker binary: %v", err)
			}

			if err = syscall.Exec(dockerPath, args, os.Environ()); err != nil {
				log.Fatalf("error: unable to start docker: %v", err)
			}
		} else if args[0] == "compose" {
			composePath, err := exec.LookPath("docker-compose")
			if err != nil {
				log.Fatalf("error: unable to find docker-compose binary: %v", err)
			}

			if err = syscall.Exec(composePath, args, os.Environ()); err != nil {
				log.Fatalf("error: unable to start docker-compose: %v", err)
			}
		}
	} else if args[0] == "ssh-forwarder" {
		if err := sshforwarder.Run(); err != nil {
			log.Fatalf("error starting forwarder: %v", err)
		}
	} else {
		usage(1)
	}
}

func usage(exitCode int) {
	fmt.Println("Usage: devenv COMMAND [arg...]")
	fmt.Println("       devenv [--help | -v | --version]")
	fmt.Println("")
	fmt.Println("A developer-friendly wrapper for Docker")
	fmt.Println("")
	fmt.Println("Commands:")
	fmt.Println("  docker  Sets up a Docker environment and executes `docker`")
	fmt.Println("  compose Sets up a Docker environment and executes `docker-compose`")
	fmt.Println("")
	fmt.Println("Examples:")
	fmt.Println("  devenv docker ps")
	fmt.Println("  devenv compose up")
	os.Exit(exitCode)
}

func printErrorsAndExit(errors []string) {
	fmt.Println("devenv cannot run until the following issues are resolved:")
	for _, error := range errors {
		fmt.Printf("  * %s\n", error)
	}
	os.Exit(1)
}
