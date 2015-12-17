## Binary `operator(1)`

See for alias ff58b4d41ccb6c79c1b9af4d499a7a8418a288d8

Generate a single binary that includes ALL services and methods defined in
services. `operator --help` should list a summary of all commands grouped by
services with a short synopsys. Example:

```
$ operator --help
Usage: operator <service> <command>

Use `operator help <service>` for help with a particular service.

Available services:

  buildkite
    Interact with the Continuous Integration server, Buildkite.com. Lets you
    retetrieve the status of projects and trigger builds.

  k8
    There is no documentation for this service.

  gcloud
    The gcloud services allows managing and querying a few Google Cloud resources
    such as computer instances and container clusters.

  papertrail
    Lets you search log indexed on Papertrail.com
```

Then each each service gets its own command or whatever:

```
$ operator help papertrail
Interact with Papertrail.com

Usage:
  operator papertrail [command]

Available Commands:
  search       Query the logs index on Papertrail.com
  archive      Archive logs to S3.
```

```
$ operator papertrail help search
Search logs indexed on Papertrail.com

Usage:
  operator papertrail-search [arguments]

Arguments
  --query The search query (String)

Examples

("something bad" program:ssh -noise) OR severity:error
program:(raid5tools ethtool)
something ("something else" OR "a third thing")
something -("but not" OR "something else")
```

**NOTE:** There needs to be some way to detect when the client is outdated. The
client should perhaps always include the version (git SHA1?) and if there is a
mismatch the server could reply with some kind of error and ask the user to
update. Ultimately though, this should become a solved problem and never be
something people have to deal with and the binary should update itself. **PUNT**
