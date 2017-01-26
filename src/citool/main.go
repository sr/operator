package main

import (
	"flag"
	"fmt"
	"os"
	"strings"
	"text/tabwriter"
)

type command interface {
	Name() string
	Description() string
	LongHelp() string
	RegisterFlags(*flag.FlagSet)
	Run() error
}

func main() {
	commands := []command{
		&extractSourcesCommand{},
		&createHerokuBuildCommand{},
	}

	overallUsage := func() {
		fmt.Fprintln(os.Stderr, "Usage: citool SUBCOMMAND [OPTIONS]")
		fmt.Fprintln(os.Stderr)
		fmt.Fprintln(os.Stderr, "Subcommands:")
		fmt.Fprintln(os.Stderr)

		tw := tabwriter.NewWriter(os.Stderr, 0, 4, 2, ' ', 0)
		for _, c := range commands {
			fmt.Fprintf(tw, "\t%s\t%s\n", c.Name(), c.Description())
		}
		_ = tw.Flush()
		fmt.Fprintln(os.Stderr)
	}

	if len(os.Args) <= 1 || len(os.Args) == 2 && strings.Contains(os.Args[1], "help") || os.Args[1] == "-h" {
		overallUsage()
		os.Exit(1)
	}

	for _, c := range commands {
		if subcmd := c.Name(); subcmd == os.Args[1] {
			fs := flag.NewFlagSet(subcmd, flag.ExitOnError)
			c.RegisterFlags(fs)

			fs.Usage = buildUsage(c, fs)
			if err := fs.Parse(os.Args[2:]); err != nil {
				fs.Usage()
				os.Exit(1)
			}

			if err := c.Run(); err != nil {
				fmt.Fprintf(os.Stderr, "%v\n", err)
				os.Exit(1)
			}

			return
		}
	}

	fmt.Fprintf(os.Stderr, "citool: no such subcommand '%s'\n", os.Args[1])
	fmt.Fprintln(os.Stderr)

	overallUsage()
	os.Exit(1)
}

func buildUsage(c command, fs *flag.FlagSet) func() {
	return func() {
		fmt.Fprintf(os.Stderr, "Usage: citool %s [OPTIONS]\n", c.Name())
		fmt.Fprintln(os.Stderr)
		fmt.Fprintln(os.Stderr, strings.TrimSpace(c.LongHelp()))
		fmt.Fprintln(os.Stderr)
		fmt.Fprintln(os.Stderr, "Options:")
		fmt.Fprintln(os.Stderr)
		fs.PrintDefaults()
	}
}
