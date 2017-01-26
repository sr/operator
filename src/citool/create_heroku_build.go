package main

import (
	"citool/heroku"
	"errors"
	"flag"
	"fmt"
	"net/http"
	"os"
)

type createHerokuBuildCommand struct {
	app     string
	file    string
	version string
}

func (c *createHerokuBuildCommand) Name() string {
	return "create-heroku-build"
}

func (c *createHerokuBuildCommand) Description() string {
	return "Creates a Heroku build from a tarball"
}

func (c *createHerokuBuildCommand) LongHelp() string {
	return `
Requires HEROKU_API_TOKEN to be set.
`
}

func (c *createHerokuBuildCommand) RegisterFlags(fs *flag.FlagSet) {
	fs.StringVar(&c.app, "app", "", "Heroku application name.")
	fs.StringVar(&c.file, "file", "/dev/stdin", "Source file (.tar.gz format).")
	fs.StringVar(&c.version, "version", "", "Heroku build version (e.g., build ID).")
}

func (c *createHerokuBuildCommand) Run() error {
	if c.app == "" {
		return errors.New("-app is required")
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

	build := &heroku.Build{
		SourceBlob: &heroku.BuildSourceBlob{
			URL:     source.SourceBlob.GetURL,
			Version: c.version,
		},
	}
	build, err = client.CreateBuild(c.app, build)
	if err != nil {
		return err
	}

	fmt.Printf("Created build '%s'\n", build.ID)
	return nil
}
