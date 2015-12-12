# Tasks

## Code generation
This encompasses both `protoc-gen-hubot` and `protoc-gen-grpcmd` used to
generate command line binaries and hubot scripts from the protobuf service
definitions, respectively.

- [ ] Fix grpcmd to accept more than one package name on the command line
- [ ] Generate the operatord main.go responsible for registering the different
  services on the GRPC server
- [ ] Rewrite `protoc-gen-grpcmd` to use same templating technique that
  `protoc-gen-hubot` is using. It's a lot more maintainable this way.
- [ ] Sneak sneak case the methods (i.e. `GCloudService.ListInstances` becomes `gcloud list-instances`)
- [ ] Sneak case the arguments. `ProjectId` becomes `-project-id`.
- [ ] Handle optional and required fields.
- [ ] Add support for int types and move away from considering everything as a
  string as much as practicaly possible.
- [ ] Generate proper help syntax for Hubot scripts to integrate with
  `/hubot help`
- [ ] Allow choosing a prefix for generated binaries, e.g. `ops-papertrail`,
  `ops-gcloud`, etc. This should be set as a protobuf option.
- [ ] Process code comments annotating the service definition, methods, and
  messages and use those to generate help messages all three levels: the
  service, its methods, and their arguments. See `gh-help` example here:
  <https://gist.github.com/anonymous/ce1784b513b67bfd7adf>
- [ ] Do the same-ish for Hubot scripts

## operatord
The operator server that's running the various services. There is nothing there
at the moment. In the future this will be responsible for logging all actions,
managing ACL, etc.
- [ ] Setup protolog with startup notice log entry.
- [ ] Figure out how to log all GRPC requests for all services. See Peter's
  interceptor stuff. Perhaps will have to write a gogo plugin if we can't
  convince GRPC core that this is a good idea.

_Note about Google Cloud Logging:_ we get for free real time logs, log metrics,
powerful querying (via Big Query), and log term archival (to Cloud Storage/S3)

## Deployment
- [ ] Deploy Hubot and operatord manually Kubernetes.
- [ ] Write an operatord service to automate away deployment of an Operator
  instance. i.e. given a Kubernetes/Google Cloud Container cluster set
  everything up, deploy new versions, etc.
- [ ] Stop using insecure connection between client and server.
- [ ] Metrics.
- [ ] Setup rsyslog container ingesting logs from Protolog via syslog protocol
and forwarding them to Google Cloud Logging via rsyslog prog. See
<http://www.rsyslog.com/doc/v8-stable/configuration/modules/omprog.html>.
- Clean-up K8s secrets stuff. Only ever write one secret, a shell file that
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
  Probably create a container then run the command. Allow people to create and
  sepcify a kitchen-sink Docker image with the runtime these existing need
  (typically a whole ubuntu/debian with extra packages and whatnot -- something
  matching their production environment)
- Investigate HTML output for chat.
