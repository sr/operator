# Notes

# Roadmap-ish

What's left before showing this to Peter

- Generate hubot scripts
- Deploy and setup hubot on bazbat
- Sort out openflights deployment
- Deploy operatord
- Implement https://github.com/atmos/hubot-ci/blob/master/src/scripts/ci.coffee
- Finish papertrail
- Finish up gcloud

After:

- Work in logging/interceptor stuff into GRPC to get going on auditing

## Command generation TODOs
- sneak-case the methods (i.e. ListInstances becomes list-instances)
- ditto for arguments (i.e. ProjectId becomes -project-id)
- --help [command]

## Audit/Logging
- Audit of all actions. Log the service, method, user, etc. Has to happen on the
  server so that both chat and shell invocations are logged. This
- This should be done in main GRPC but might have to fork it in the main team.
  See <https://github.com/grpc/grpc-go/pull/349>
- Obviously use protolog and write log entries to Google Cloud Logging at first.
  This buys: real time logs, metrics (via logs), powerful querying (via Big
  Query), and log term archivale.

## Code generation, formatting

- Pretty apparent that I will have to generate both the CLI and Hubot code.
- CLI written in Golang and thus can perhaps reuse the code generation
  plug-in system. See pointers given by Peter on Slack. Essentially need to
  translate Services into commands and Methods `FooRequest` structs into flags.
- Generating node code will be trickier... perhaps can get away with doing more
  dynamic/meta stuff there at first.... or just do templates in Golang.
- All logic should be on the server. This includes formatting. No point
  duplicating the formatting in both the CLI and Hubot. Both clients must be
  extremely simple. Issue a request, dump the response (or an error message) to
  the "screen" (i.e. stdout for the CLI, chat room for Hubot). So just include
  a Output field with `FooResponse` structs that includes e.g.

		struct Output {
			HTML string
			Text string
		}
		struct LogSearchResponse {
			Output &Output{HTML: "<li>log</li>", PlainText: "boom"}
		}

# Misc
- Global configuration
- Per-user configuration storage (?) e.g.
	- default gcloud project id
	- papertrail token

# Commands

```
https://cloud.google.com/compute/docs/reference/latest/projects/setUsageExportBucket

/dev list
/routes sfo bru
/routes sfo vienna
/shutdown dev6-fra1
/gcloud snapshot xxxxx
/gcloud list
/gcloud mkdev us-central
/gcloud usage
/gcloud enable-usage
/ansible dev dev6-us-central1
/papertrail program=cbk at=finish
/ci projects
```

# ?

- Bake ideas in pachyderm/ops repo
- Move into pachyderm/pachyderm once mature and or generalized or extra into
  other repository. e.g. devmachine (manage dev machines with ansible and shell
  script or chatops)

# Workflow

- Create new dev machine in Belgium based off of latest Google Cloud snapshot
- Setup forwarding to Papertrail for all dev machines

# Setup Hubot

- Docker image containing Hubot with Slack adapter, plugins, etc
- Kubernetes configuration for Hubot and Redis brain
- Switch to using simple file-based brain adapter storing on a Persistent Volume
- Embed tokens etc directly in K8 configs
- Figure out how to use K8 secrets for that instead...
- Operator docker image build chain

- Stream long running command output to Syslog/Papertrail. Append a unique
  event identifier, e.g. event=UUID output=msg
- Paste search URL, e.g. papertrail.com/events?q=event=$UUID

- Grabs hosts via Google Cloud API
- Writes hosts file usable by ansible ([tag_ci]; ip1; ip2; etc)
- Use K8 secret API to store private/public key
- Retrieve keys from File System and write them to temporary file for ansible-playbook(1) to use
- Invoke ansible-playbook with proper arguments etc
