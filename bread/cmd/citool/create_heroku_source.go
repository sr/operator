package main

import (
	"errors"
	"flag"
	"fmt"
	"net/http"
	"os"

	"git.dev.pardot.com/Pardot/infrastructure/bread/heroku"
)

type createHerokuSourceCommand struct {
	app     string
	file    string
	version string
}

func (c *createHerokuSourceCommand) Name() string {
	return "create-heroku-source"
}

func (c *createHerokuSourceCommand) Description() string {
	return "Creates a Heroku source from a tarball"
}

func (c *createHerokuSourceCommand) LongHelp() string {
	return `
Creates a Heroku source blob from a tarball. Requires HEROKU_API_TOKEN to be set.

Examples:

  citool create-heroku-source --app=pardot-foo --file=source.tar.gz --version=sha123
`
}

func (c *createHerokuSourceCommand) RegisterFlags(fs *flag.FlagSet) {
	fs.StringVar(&c.app, "app", "", "Heroku application name.")
	fs.StringVar(&c.file, "file", "", "Source file (.tar.gz format).")
	fs.StringVar(&c.version, "version", "", "Heroku build version (e.g., build ID).")
}

func (c *createHerokuSourceCommand) Run() error {
	if c.app == "" {
		return errors.New("-app is required")
	} else if c.file == "" {
		return errors.New("-file is required")
	}

	apiToken := os.Getenv("HEROKU_API_TOKEN")
	if apiToken == "" {
		return errors.New("HEROKU_API_TOKEN is required")
	}

	inFile, err := os.Open(c.file)
	if err != nil {
		return err
	}
	defer func() { _ = inFile.Close() }()

	inFileStat, err := inFile.Stat()
	if err != nil {
		return err
	}

	client := heroku.NewClient(apiToken)
	source, err := client.CreateSource(c.app)
	if err != nil {
		return err
	} else if source.SourceBlob == nil {
		return errors.New("source.SourceBlob is nil")
	}

	req, err := http.NewRequest("PUT", source.SourceBlob.PutURL, inFile)
	if err != nil {
		return err
	}
	req.ContentLength = inFileStat.Size()

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	} else if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("HTTP %d when uploading the source file", resp.StatusCode)
	}

	fmt.Printf("%s\n", source.SourceBlob.GetURL)
	return nil
}
