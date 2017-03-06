# pull_agent

Deploys your code!

## Overview

Pull Agent runs on each of our servers. Every minute, a Pull Agent process spins up and queries [Canoe] to see if there is anything to deploy. If there is, the Pull Agent process pulls down the requested deployment artifact from [Artifactory], decompresses it, and marks it as 'current'

Pull Agent also supports the concept of a global restart. After every server has finished deploying new code, one server per datacenter is designated as the 'restart' server to perform restart tasks. Restart tasks typically include restarting a global job system or other global concerns.

## Usage

```bash
bundle exec bin/pull-agent ENVIRONMENT PROJECT

# or, if installed as a gem (like we do in production):
pull-agent ENVIRONMENT PROJECT
```

* `ENVIRONMENT` is typically `staging` or `production`
* `PROJECT` maps to a [deployer] that knows how to deploy a project such as `pardot` or `workflow-stats`

## Deployers

Every project that Pull Agent can deploy must have a deployer defined for it. A deployer is a Ruby class that follows an interface (described below) and is responsible for deploying a given project. For instance, there is a deployer for the Pardot application and also a deployer for Workflow Stats.

A deployer follows the interface:

### initialize(environment, deploy)

A Deployer accepts the current `environment` (as a string; e.g., "production" or "staging") and a [Deploy object] describing the current requested deployment.

### deploy

When invoked, the Deployer should do whatever is necessary to deploy new code to this server, including restarting any services local to this server. Check out the [Pardot Deployer] for a good example.

### restart

When invoked, the Deployer should do whatever is necessary to restart any global services. This method is invoked only after every server in the datacenter has deployed new code. It is acceptable to leave this method blank if there are no global services to restart.

[deployer]: #deployers
[Canoe]: ../canoe
[Artifactory]: https://artifactory.dev.pardot.com
[Deploy Object]: lib/pull_agent/deploy.rb
[Pardot Deployer]: lib/pull_agent/deployers/pardot.rb
