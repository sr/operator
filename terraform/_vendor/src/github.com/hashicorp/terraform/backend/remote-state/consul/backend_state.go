package consul

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform/backend"
	"github.com/hashicorp/terraform/state"
	"github.com/hashicorp/terraform/state/remote"
	"github.com/hashicorp/terraform/terraform"
)

const (
	keyEnvPrefix = "-env:"
)

func (b *Backend) States() ([]string, error) {
	// Get the Consul client
	client, err := b.clientRaw()
	if err != nil {
		return nil, err
	}

	// List our raw path
	prefix := b.configData.Get("path").(string) + keyEnvPrefix
	keys, _, err := client.KV().Keys(prefix, "/", nil)
	if err != nil {
		return nil, err
	}

	// Find the envs, we use a map since we can get duplicates with
	// path suffixes.
	envs := map[string]struct{}{}
	for _, key := range keys {
		// Consul should ensure this but it doesn't hurt to check again
		if strings.HasPrefix(key, prefix) {
			key = strings.TrimPrefix(key, prefix)

			// Ignore anything with a "/" in it since we store the state
			// directly in a key not a directory.
			if idx := strings.IndexRune(key, '/'); idx >= 0 {
				continue
			}

			envs[key] = struct{}{}
		}
	}

	result := make([]string, 1, len(envs)+1)
	result[0] = backend.DefaultStateName
	for k := range envs {
		result = append(result, k)
	}

	return result, nil
}

func (b *Backend) DeleteState(name string) error {
	if name == backend.DefaultStateName {
		return fmt.Errorf("can't delete default state")
	}

	// Get the Consul API client
	client, err := b.clientRaw()
	if err != nil {
		return err
	}

	// Determine the path of the data
	path := b.path(name)

	// Delete it. We just delete it without any locking since
	// the DeleteState API is documented as such.
	_, err = client.KV().Delete(path, nil)
	return err
}

func (b *Backend) State(name string) (state.State, error) {
	// Get the Consul API client
	client, err := b.clientRaw()
	if err != nil {
		return nil, err
	}

	// Determine the path of the data
	path := b.path(name)

	// Determine whether to gzip or not
	gzip := b.configData.Get("gzip").(bool)

	// Build the state client
	var stateMgr state.State = &remote.State{
		Client: &RemoteClient{
			Client: client,
			Path:   path,
			GZip:   gzip,
		},
	}

	// If we're not locking, disable it
	if !b.lock {
		stateMgr = &state.LockDisabled{Inner: stateMgr}
	}

	// Get the locker, which we know always exists
	stateMgrLocker := stateMgr.(state.Locker)

	// Grab a lock, we use this to write an empty state if one doesn't
	// exist already. We have to write an empty state as a sentinel value
	// so States() knows it exists.
	lockInfo := state.NewLockInfo()
	lockInfo.Operation = "init"
	lockId, err := stateMgrLocker.Lock(lockInfo)
	if err != nil {
		return nil, fmt.Errorf("failed to lock state in Consul: %s", err)
	}

	// Local helper function so we can call it multiple places
	lockUnlock := func(parent error) error {
		if err := stateMgrLocker.Unlock(lockId); err != nil {
			return fmt.Errorf(strings.TrimSpace(errStateUnlock), lockId, err)
		}

		return parent
	}

	// Grab the value
	if err := stateMgr.RefreshState(); err != nil {
		err = lockUnlock(err)
		return nil, err
	}

	// If we have no state, we have to create an empty state
	if v := stateMgr.State(); v == nil {
		if err := stateMgr.WriteState(terraform.NewState()); err != nil {
			err = lockUnlock(err)
			return nil, err
		}
		if err := stateMgr.PersistState(); err != nil {
			err = lockUnlock(err)
			return nil, err
		}
	}

	// Unlock, the state should now be initialized
	if err := lockUnlock(nil); err != nil {
		return nil, err
	}

	return stateMgr, nil
}

func (b *Backend) path(name string) string {
	path := b.configData.Get("path").(string)
	if name != backend.DefaultStateName {
		path += fmt.Sprintf("%s%s", keyEnvPrefix, name)
	}

	return path
}

const errStateUnlock = `
Error unlocking Consul state. Lock ID: %s

Error: %s

You may have to force-unlock this state in order to use it again.
The Consul backend acquires a lock during initialization to ensure
the minimum required key/values are prepared.
`