# Tasks

## Demo

Focus on a small subset of services that would speak to the audience... Probably
just **CI and deploy** at first.

- [ ] lstoll
- [ ] holman
- [ ] wfarr
- [ ] jfryman
- [ ] imbriaco

**FOCUS: Build and deploy operator using operator**

## Code generation
This encompasses both `protoc-gen-hubot` and `protoc-gen-grpcmd` used to
generate command line binaries and hubot scripts from the protobuf service
definitions, respectively.

- [ ] If the input has only one field then just do `/service method (.*?)` in Hubot
- [ ] protoc --cmd_out=~/tmp/openflights $GOPATH/src/go.pedge.io/openflights/openflights.proto
	should work (it currently segfaults)
- [x] Switch to go.pedge.io/protoeasy for generating code with protoc
- [ ] Contribute grpcinstrument plugin to protoeasy
- [x] Fix grpcmd to accept more than one package name on the command line
- [x] Update binaries to connect to OPERATORD_ADDRESS or something
- [x] Generate the operatord main.go responsible for registering the different
  services on the GRPC server
- [x] Rewrite `protoc-gen-grpcmd` to use same templating technique that
  `protoc-gen-hubot` is using. It's a lot more maintainable this way.
- [x] Sneak sneak case the methods (i.e. `GCloudService.ListInstances` becomes `gcloud list-instances`)
- [x] Sneak case the arguments. `ProjectId` becomes `-project-id`.
- [ ] Handle optional and required fields.
- [ ] Add support for int types and move away from considering everything as a
  string as much as practicaly possible.
- [ ] Generate proper help syntax for Hubot scripts to integrate with
  `/hubot help`
- [ ] Process code comments annotating the service definition, methods, and
  messages and use those to generate help messages all three levels: the
  service, its methods, and their arguments. See `gh-help` example here:
  <https://gist.github.com/anonymous/ce1784b513b67bfd7adf>
- [ ] Do the same-ish for Hubot scripts

## operatord
The operator server that's running the various services. There is nothing there
at the moment. In the future this will be responsible for logging all actions,
managing ACL, etc.
- [x] Setup protolog with startup notice log entry.
- [x] Figure out how to log all GRPC requests for all services. See Peter's
  interceptor stuff. Perhaps will have to write a gogo plugin if we can't
  convince GRPC core that this is a good idea.

_Note about Google Cloud Logging:_ we get for free real time logs, log metrics,
powerful querying (via Big Query), and log term archival (to Cloud Storage/S3)

## Deployment
- [x] Deploy Hubot and operatord manually to Kubernetes.
- [ ] Setup prometheus / metrics
- [ ] Write an operatord service to automate away deployment of an Operator
  instance. i.e. given a Kubernetes/Google Cloud Container cluster set
  everything up, deploy new versions, etc.
- [ ] Stop using insecure connection between client and server.
- [ ] Setup rsyslog container ingesting logs from Protolog via syslog protocol
and forwarding them to Google Cloud Logging via rsyslog prog. See
<http://www.rsyslog.com/doc/v8-stable/configuration/modules/omprog.html>.
- [ ] Clean-up K8s secrets stuff. Only ever write one secret, a shell file that
  exports all secrets and can be sourced in by all controllers
  ```
  export TOKEN="boomtown"
  ENTRYPOINT ["/k8s-exec /operatord"]
  ```
  Or perhaps even better, do this in Go so bash isn't required in the container
  (i.e. works with FROM scratch), nor is mounting the actual secret volume (or
  is it?) read data using the API (see
  <http://kubernetes.io/v1.1/docs/api-reference/v1/definitions.html#_v1_secret>)
  and sets os.Setenv(k,v). Perhaps something like... k8secrets.Setenv().
  Requires figuring out how to connect to the agent from within a pod.

# Miscelleanous long term/vague stuff
- Generator/Command line utility that generates services skeleton. This is key.
- Come up with a service that can execute arbitrary shell commands to integrate
  with shops that already have tons of these shell scripts scripts all over the
  place or for e.g. executing things like ansible-playbook(1) or puppet(1).
  Probably create a container or pod using either the Docker or Kubernetes API
  then run the command in it. Allow people to create and specify a kitchen-sink
  like Docker image with the runtime these existing need (typically a whole
  ubuntu/debian with extra packages and whatnot -- something matching their
  production environment)
- Investigate rich formatting/HTML output for chat.
- Utimately Operator should become a library and a command that people install
  and then use to boot their own server/bootstrap their own services etc. not
  have to clone/fork this repository and know what make targets to call to
  recompile their main (!!), build docker images etc. Probably provide commands
  such as `operator build` to build Docker image(s) (server daemon + hubot) form
  the set of services present in the repo. Advice against checking in generated
  files... Maybe? What about Hubot scripts? These have to live a separate
  repo...
  Maybe something like:
    # generate hubot scripts into existing company's hubot repository
    $ operator build ~/src/{ops,dev}/services/*.proto --hubot ~src/hubot
    # build single "operator" binary for all services listed then upload to s3
    $ operator build ~/src/{ops,dev}/services/*.proto --cmd ~/tmp/operator --upload s3://my-bucket/
    # build operatord (server) binary inside docker then create a docker image setup to run it
      that can be pushed to whatever registry (and then deployed to ecs/gcloud/kubernetes/...)
    $ operator build ~/src/{ops,dev}/services/*.proto

## Services

- [ ] Spin up/spin down Operator kubernetes cluster
- [ ] /gcloud enable-http dev1-europe-west1b
- [ ] /gcloud list-instances shows tag
- [ ] /gcloud (un)tag instance=instance-id tags=tag1,tag2
