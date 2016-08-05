package docker

import "os/exec"

func IsInstalled() bool {
	if _, err := exec.LookPath("docker"); err != nil {
		return false
	}
	return true
}

func Pull(args ...string) ([]byte, error) {
	return clientExec("pull", args)
}

func Run(args ...string) ([]byte, error) {
	return clientExec("run", args)
}

func Kill(args ...string) ([]byte, error) {
	return clientExec("kill", args)
}

func Rm(args ...string) ([]byte, error) {
	return clientExec("rm", args)
}

func Inspect(args ...string) ([]byte, error) {
	return clientExec("inspect", args)
}

func clientExec(subcommand string, args []string) ([]byte, error) {
	args = append([]string{subcommand}, args...)
	cmd := exec.Command("docker", args...)
	return cmd.CombinedOutput()
}
