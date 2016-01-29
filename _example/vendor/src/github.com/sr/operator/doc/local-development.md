Local Development
=================

Start the operatord daemon:

```
export PAPERTRAIL_API_TOKEN=secret
export PAPERTRAIL_BUILDKITE_TOKEN=secret
make operatord-dev
```

Start an interactive, local Hubot with `make hubot-dev`.

Run `make build install` to compile and install the binaries for interacting
with the services installed on the server (`buildkite`, `gcloud`, and
`papertrail` at the moment)

After changing any of the code generation code (`protoc-gen-cmd`,
`protoc-gen-hubot`, and `protoc-gen-operatord`) be sure to regenerate all code
like this:

```
make build install proto
```
