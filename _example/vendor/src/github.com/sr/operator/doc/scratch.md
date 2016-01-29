Scratch/braindump
=================

## Miscelleanous long term/vague stuff
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

## Services ideas
- [ ] Spin up/spin down dev machine
- [ ] Spin up/spin down Operator kubernetes cluster
- [ ] /gcloud enable-http dev1-europe-west1b
- [ ] /gcloud list-instances shows tag
- [ ] /gcloud (un)tag instance=instance-id tags=tag1,tag2
