Sync Scripts
============

A set of Ruby scripts that will sync the Pardot repos to the appropriate servers.


-----------------------------------------------------------------------------

Usage
=====

      ship-it.rb <environment> [<payload>] [options]
        With no options: grab the latest tag for pardot and begin the sync process.

        Arguments:
          help : this message

          <environment> : [REQUIRED] environment to sync. options: production, staging, test, dev

          <payload> : the payload to sync. options: pardot, pithumbs (will default to pardot)

          tag=<tag> : specify full tag to pull for sync
          commit=<hash> : specify hash to pull for sync (overrides tag flags)
          hash=<hash> : same as commit
          branch=<branch> : specify branch to pull for sync (overrides tag and commit flags)

          --server[s]=<server info> : only sync to the specified server.

          --rollback : revert to the previous deployment
          --lock : lock the current environment (also syncs)
          --only-lock : lock the current environment (does not sync)
          --unlock : remove the existing lock only if you created it (does not sync)
          --force-unlock : forcefully unlock environment, even if you did not lock originally
          --no-color : no fancy output - just black text
          --html-color : output using HTML colors in span tags (for canoe)
          --list-servers : provide a list of servers used in sync (does not sync)


Production
==========