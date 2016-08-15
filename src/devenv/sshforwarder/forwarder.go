package sshforwarder

import (
	"bytes"
	"devenv"
	"devenv/docker"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"strings"
	"time"
)

const (
	sshForwaderContainerName = "devenv-ssh-forwarder"
	sshForwarderContainerURL = "docker.dev.pardot.com/base/ssh-forwarder"

	containerVolumeMountPath = "/tmp/ssh-agent"
	sshAuthSockPathFile      = "ssh-auth-sock.path"
)

func Run() error {
	if err := ensureSSHForwarderStopped(); err != nil {
		return err
	}

	sshAgentPath, err := devenv.EnsurePersistentDirectoryCreated("ssh-agent", true)
	if err != nil {
		return err
	}

	home := os.Getenv("HOME")
	output, err := docker.Run("-d",
		"--security-opt", "seccomp:unconfined",
		"-v", fmt.Sprintf("%s:/tmp", sshAgentPath),
		"-v", fmt.Sprintf("%s/.ssh/id_rsa.pub:/root/.ssh/authorized_keys", home),
		"--publish-all",
		"--name", sshForwaderContainerName,
		sshForwarderContainerURL,
	)
	if err != nil {
		return err
	}

	output, err = docker.Inspect(
		"--format={{index . \"NetworkSettings\" \"Ports\" \"22/tcp\" 0 \"HostPort\"}}",
		sshForwaderContainerName,
	)
	if err != nil {
		return err
	}
	sshPort := bytes.TrimSpace(output)

	for {
		cmd := exec.Command(
			"ssh",
			"-A",
			"-p", string(sshPort),
			"-o", "StrictHostKeyChecking=no",
			"-o", "UserKnownHostsFile=/dev/null",
			"-o", fmt.Sprintf("IdentityFile=%s/.ssh/id_rsa", home),
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

func IsStarted() bool {
	output, err := docker.Inspect("--format={{.State.Running}}", sshForwaderContainerName)
	return err == nil && bytes.Contains(output, []byte("true"))
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

func ensureSSHForwarderStopped() error {
	if output, err := docker.Kill(sshForwaderContainerName); err != nil {
		if bytes.Contains(output, []byte("No such container")) {
			// Nothing more to do
			return nil
		} else if bytes.Contains(output, []byte("is not running")) {
			// Container is not running.
		} else {
			return err
		}
	}

	if output, err := docker.Rm(sshForwaderContainerName); err != nil {
		if bytes.Contains(output, []byte("No such container")) {
			// Nothing more to do
			return nil
		}

		return err
	}

	return nil
}
