package devenv

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"strings"
	"time"

	"github.com/fsouza/go-dockerclient"

	"golang.org/x/net/context"
)

const (
	sshForwarderContainerName = "devenv-ssh-forwarder"
	sshForwarderContainerURL  = "docker.dev.pardot.com/base/ssh-forwarder"
	sshForwarderRegistry      = "docker.dev.pardot.com"

	containerVolumeMountPath = "/tmp/ssh-agent"
	sshAuthSockPathFile      = "ssh-auth-sock.path"
)

type SSHForwarder struct {
	client *docker.Client
	logger *log.Logger
}

func (f *SSHForwarder) Run(ctx context.Context) error {
	if err := f.ensureSSHForwarderStopped(ctx); err != nil {
		return err
	}

	sshAgentPath, err := EnsurePersistentDirectoryCreated("ssh-agent", true)
	if err != nil {
		return err
	}

	// If the auth socket isn't ready, it's better for us to exit and get
	// relaunched by launchd after ssh-agent is properly setup
	if err := f.sshAuthSockReady(); err != nil {
		return err
	}

	_, err = f.client.InspectImage(sshForwarderContainerURL)
	if err == docker.ErrNoSuchImage {
		authConfigs, err := docker.NewAuthConfigurationsFromDockerCfg()
		if err != nil {
			return err
		}

		pullOpts := docker.PullImageOptions{
			Repository: sshForwarderContainerURL,
			Context:    ctx,
		}
		if err := f.client.PullImage(pullOpts, authConfigs.Configs[sshForwarderRegistry]); err != nil {
			return err
		}
	} else if err != nil {
		return err
	}

	createOpts := docker.CreateContainerOptions{
		Name: sshForwarderContainerName,
		Config: &docker.Config{
			Image: sshForwarderContainerURL,
		},
		HostConfig: &docker.HostConfig{
			Binds: []string{
				fmt.Sprintf("%s:/tmp", sshAgentPath),
				fmt.Sprintf("%s/.ssh/id_rsa.pub:/root/.ssh/authorized_keys:ro", os.Getenv("HOME")),
			},
			PublishAllPorts: true,
		},
		Context: ctx,
	}

	if _, err := f.client.CreateContainer(createOpts); err != nil {
		return err
	}

	if err := f.client.StartContainer(sshForwarderContainerName, nil); err != nil {
		return err
	}

	container, err := f.client.InspectContainer(sshForwarderContainerName)
	if err != nil {
		return err
	}

	sshPortMappings, ok := container.NetworkSettings.Ports["22/tcp"]
	if !ok || len(sshPortMappings) <= 0 {
		return fmt.Errorf("unable to find port mapping for 22/tcp")
	}

	f.logger.Printf("SSH_AUTH_SOCK=%v\n", os.Getenv("SSH_AUTH_SOCK"))
	f.logger.Printf("attempting to ssh to the ssh-forwarder container\n")

	errSSHC := make(chan error)
	stopSSHC := make(chan interface{})
	go func() { errSSHC <- f.forwardAgentOverSSH(sshPortMappings[0].HostPort, stopSSHC) }()

	for {
		select {
		case <-time.After(5 * time.Second):
			if err := f.sshAuthSockReady(); err != nil {
				// The SSH_AUTH_SOCK is no longer available. ssh-agent may have restarted.
				// In this case, we need to crash ourselves and restart too.
				stopSSHC <- true
				_ = <-errSSHC
				return err
			}
		case err := <-errSSHC:
			return err
		}
	}
}

func (f *SSHForwarder) IsStarted() bool {
	container, err := f.client.InspectContainer(sshForwarderContainerName)
	if err != nil {
		return false
	}

	return container.State.Running
}

func (f *SSHForwarder) DockerVolume() (string, error) {
	sshAgentPath, err := EnsurePersistentDirectoryCreated("ssh-agent", false)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%s:%s", sshAgentPath, containerVolumeMountPath), nil
}

func (f *SSHForwarder) DockerSSHAuthSock() (string, error) {
	sshAgentPath, err := EnsurePersistentDirectoryCreated("ssh-agent", false)
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

func (f *SSHForwarder) ensureSSHForwarderStopped(ctx context.Context) error {
	opts := docker.RemoveContainerOptions{
		ID:      sshForwarderContainerName,
		Force:   true,
		Context: ctx,
	}
	if err := f.client.RemoveContainer(opts); err != nil {
		if _, ok := err.(*docker.NoSuchContainer); ok {
			return nil
		}
		return err
	}

	return nil
}

func (f *SSHForwarder) sshAuthSockReady() error {
	authSock := os.Getenv("SSH_AUTH_SOCK")
	if authSock == "" {
		return fmt.Errorf("SSH_AUTH_SOCK is unset")
	}

	if _, err := os.Stat(authSock); err != nil {
		return fmt.Errorf("unable to stat %v: %v", authSock, err)
	}

	return nil
}

func (f *SSHForwarder) forwardAgentOverSSH(hostPort string, stop <-chan interface{}) error {
	for {
		cmd := exec.Command(
			"ssh",
			"-A",
			"-p", hostPort,
			"-o", "StrictHostKeyChecking=no",
			"-o", "UserKnownHostsFile=/dev/null",
			"-o", fmt.Sprintf("IdentityFile=%s/.ssh/id_rsa", os.Getenv("HOME")),
			"root@127.0.0.1",
			fmt.Sprintf("echo \"$SSH_AUTH_SOCK\" > /tmp/%s && sleep inf", sshAuthSockPathFile),
		)
		var buf bytes.Buffer
		cmd.Stdin = nil
		cmd.Stdout = &buf
		cmd.Stderr = &buf

		if err := cmd.Start(); err != nil {
			return err
		}

		waitC := make(chan error)
		go func() { waitC <- cmd.Wait() }()

		select {
		case err := <-waitC:
			output := buf.String()
			f.logger.Printf("ssh output: %s\n", output)

			if err != nil {
				// Some errors are allowed to account for a race between the Docker
				// SSH container starting, and our ability to SSH to it.
				potentialStartupErrors := []string{
					"Connection refused",
					"Connection closed by remote host",
				}

				startupError := false
				for _, potentialError := range potentialStartupErrors {
					if strings.Contains(output, potentialError) {
						startupError = true
						break
					}
				}

				if !startupError {
					return err
				}
			} else {
				f.logger.Printf("ssh exited normally, restarting")
			}
		case <-stop:
			_ = cmd.Process.Kill()
			_ = cmd.Wait()
			return nil
		}

		select {
		case <-time.After(1 * time.Second):
			continue
		case <-stop:
			_ = cmd.Process.Kill()
			_ = cmd.Wait()
			return nil
		}
	}
}
