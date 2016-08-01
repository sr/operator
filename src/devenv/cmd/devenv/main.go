package main

import (
	"fmt"
	"os"
	"syscall"
)

func main() {
	// TODO: Check if Docker for Mac is installed

	args := os.Args[1:]
	if len(args) <= 0 || args[0] == "--help" || args[0] == "-h" {
		usage(0)
	} else if args[0] == "--version" || args[0] == "-v" {
		// TODO: Version information
	} else if args[0] == "docker" {
		// TODO: Setup environment, etc.
		panic(syscall.Exec("/usr/local/bin/docker", args, []string{}))
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
