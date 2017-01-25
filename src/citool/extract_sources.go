package main

import (
	"archive/tar"
	"bytes"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/fsouza/go-dockerclient"
)

type sourceList []string

func (l *sourceList) String() string {
	return fmt.Sprintf("%v", *l)
}
func (l *sourceList) Set(value string) error {
	*l = append(*l, value)
	return nil
}

type extractSourcesCommand struct {
	image   string
	file    string
	sources sourceList
}

func (c *extractSourcesCommand) Name() string {
	return "extract-sources"
}

func (c *extractSourcesCommand) Description() string {
	return "Extract sources from a Docker container into a tarball"
}

func (c *extractSourcesCommand) LongHelp() string {
	return `
Extracts sources from a Docker container into a tarball. The Docker container must be a running or (preferably) stopped container. Multiple paths can be extracted to multiple destination paths.

Examples:

  # Extracts /app from Docker image foo:BUILD-1234 to the root path of a tarball
  citool extract-sources --image=foo:BUILD-1234 --source=/app:/ --file=app.tar
`
}

func (c *extractSourcesCommand) RegisterFlags(fs *flag.FlagSet) {
	fs.StringVar(&c.image, "image", "", "Docker image name and tag.")
	fs.StringVar(&c.file, "file", "/dev/stdout", "Output file.")
	fs.Var(&c.sources, "source", "List of sources to extract in the form SRC:DST. Can be specified multiple times.")
}

func (c *extractSourcesCommand) Run() error {
	if c.image == "" {
		return errors.New("-image is required")
	}

	client, err := docker.NewClientFromEnv()
	if err != nil {
		return err
	}

	container, err := client.CreateContainer(docker.CreateContainerOptions{
		Config: &docker.Config{
			Image: c.image,
			Cmd:   []string{"/bin/false"},
		},
	})
	if err != nil {
		return err
	}
	defer c.removeContainer(client, container)

	if err = c.extractFiles(client, container); err != nil {
		return err
	}
	return nil
}

func (c *extractSourcesCommand) extractFiles(client *docker.Client, container *docker.Container) error {
	// TODO: Could probably be parallelized if benchmarks show it would help
	for _, source := range c.sources {
		parts := strings.Split(source, ":")
		if len(parts) != 2 {
			return fmt.Errorf("invalid SRC:DEST specification: '%s'", source)
		}
		sourcePath := strings.TrimPrefix(parts[0], "/")
		destPath := strings.TrimPrefix(parts[1], "/")

		downloadStream := &bytes.Buffer{}
		err := client.DownloadFromContainer(container.ID, docker.DownloadFromContainerOptions{
			OutputStream: downloadStream,
			Path:         sourcePath,
		})
		if err != nil {
			return err
		}

		outFile, err := os.Create(c.file)
		if err != nil {
			return err
		}
		defer func() { _ = outFile.Close() }()

		tarReader := tar.NewReader(downloadStream)
		tarWriter := tar.NewWriter(outFile)
		buf := make([]byte, 16384)
		for {
			header, err := tarReader.Next()
			if err == io.EOF {
				break
			} else if err != nil {
				return err
			}

			// Rewrite filename of /src/foo to /dst/foo
			relPath, err := filepath.Rel(sourcePath, header.Name)
			if err != nil {
				return err
			}
			header.Name = filepath.Join(destPath, relPath)

			if err := tarWriter.WriteHeader(header); err != nil {
				return err
			}

			for {
				n, err := tarReader.Read(buf)
				if err == io.EOF {
					break
				} else if err != nil {
					return err
				}

				_, err = tarWriter.Write(buf[0:n])
				if err != nil {
					return err
				}
			}
		}

		if err := tarWriter.Close(); err != nil {
			return err
		}
	}

	return nil
}

func (c *extractSourcesCommand) removeContainer(client *docker.Client, container *docker.Container) {
	// Remove the container as a best effort
	_ = client.RemoveContainer(docker.RemoveContainerOptions{
		ID:    container.ID,
		Force: true,
	})
}
