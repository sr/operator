package sshforwarder

import (
	"bytes"
	"devenv"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"strings"
	"time"

	"golang.org/x/net/context"

	"github.com/fsouza/go-dockerclient"
)

const (
	sshForwarderContainerName = "devenv-ssh-forwarder"
	sshForwarderContainerURL  = "docker.dev.pardot.com/base/ssh-forwarder"

	containerVolumeMountPath = "/tmp/ssh-agent"
	sshAuthSockPathFile      = "ssh-auth-sock.path"
)

func Run(client *docker.Client, ctx context.Context) error {
	if err := ensureSSHForwarderStopped(client, ctx); err != nil {
		return err
	}

	sshAgentPath, err := devenv.EnsurePersistentDirectoryCreated("ssh-agent", true)
	if err != nil {
		return err
	}

	opts := docker.CreateContainerOptions{
		Name: sshForwarderContainerName,
		Config: &docker.Config{
			Image: sshForwarderContainerURL,
		},
		HostConfig: &docker.HostConfig{
			Binds: []string{
				fmt.Sprintf("%s/tmp:/tmp", sshAgentPath),
				fmt.Sprintf("%s/.ssh/id_rsa.pub:/root/.ssh/authorized_keys:ro", os.Getenv("HOME")),
			},
			PublishAllPorts: true,
		},
		Context: ctx,
	}

	if _, err := client.CreateContainer(opts); err != nil {
		return err
	}

	if err := client.StartContainer(sshForwarderContainerName, nil); err != nil {
		return err
	}

	container, err := client.InspectContainer(sshForwarderContainerName)
	if err != nil {
		return err
	}

	sshPortMappings, ok := container.NetworkSettings.Ports["22/tcp"]
	if !ok || len(sshPortMappings) <= 0 {
		return fmt.Errorf("unable to find port mapping for 22/tcp")
	}

	for {
		cmd := exec.Command(
			"ssh",
			"-A",
			"-p", sshPortMappings[0].HostPort,
			"-o", "StrictHostKeyChecking=no",
			"-o", "UserKnownHostsFile=/dev/null",
			"-o", fmt.Sprintf("IdentityFile=%s/.ssh/id_rsa", os.Getenv("HOME")),
			"root@127.0.0.1",
			fmt.Sprintf("echo \"$SSH_AUTH_SOCK\" > /tmp/%s && sleep inf", sshAuthSockPathFile),
		)

		output, err := cmd.CombinedOutput()
		if err != nil {
			potentialStartupErrors := [][]byte{
				[]byte("Connection refused"),
				[]byte("Connection closed by remote host"),
			}

			startupError := false
			for _, potentialError := range potentialStartupErrors {
				if bytes.Contains(output, potentialError) {
					startupError = true
					break
				}
			}

			if !startupError {
				return err
			}
		} else {
			return nil
		}

		time.Sleep(1 * time.Second)
	}
}

func IsStarted(client *docker.Client) bool {
	container, err := client.InspectContainer(sshForwarderContainerName)
	if err != nil {
		return false
	}

	return container.State.Running
}

func DockerVolume() (string, error) {
	sshAgentPath, err := devenv.EnsurePersistentDirectoryCreated("ssh-agent", false)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%s:%s", sshAgentPath, containerVolumeMountPath), nil
}

func DockerSSHAuthSock() (string, error) {
	sshAgentPath, err := devenv.EnsurePersistentDirectoryCreated("ssh-agent", false)
	if err != nil {
		return "", err
	}

	contents, err := ioutil.ReadFile(path.Join(sshAgentPath, sshAuthSockPathFile))
	if err != nil {
		return "", err
	}

	return path.Join(
		containerVolumeMountPath,
		strings.TrimPrefix(strings.TrimSpace(string(contents)), "/tmp"),
	), nil
}

func ensureSSHForwarderStopped(client *docker.Client, ctx context.Context) error {
	opts := docker.RemoveContainerOptions{
		ID:      sshForwarderContainerName,
		Force:   true,
		Context: ctx,
	}
	if err := client.RemoveContainer(opts); err != nil {
		if _, ok := err.(*docker.NoSuchContainer); ok {
			return nil
		}
		return err
	}

	return nil
}
