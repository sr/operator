# Quick Start

Join the [#chatoops](https://bazbat.slack.com/messages/chatoops/) channel on
Slack and run commands via Hubot:

<img width="1031" alt="screenshot 2015-12-12 21 53 39"
src="https://cloud.githubusercontent.com/assets/90/11763839/fd7178ac-a11a-11e5-9312-e4b3f58cb3d0.png">

Now do the same from your tirminal. Install the service programs bundled in
this repository:

```
go get github.com/sr/operator/src/...
```

Configure the binaries to talk with the server deployed on Google Cloud:

```
export OPERATORD_ADDRESS=104.155.67.97:3000
```

Run some commands to interact with the server:

```
$ papertrail search -query program:sshd | head -5
error: Received disconnect from 189.57.57.218: 3: com.jcraft.jsch.JSchException: Auth fail [preauth]
error: Received disconnect from 189.57.57.218: 3: com.jcraft.jsch.JSchException: Auth fail [preauth]
error: Received disconnect from 189.57.57.218: 3: com.jcraft.jsch.JSchException: Auth fail [preauth]
error: Received disconnect from 189.57.57.218: 3: com.jcraft.jsch.JSchException: Auth fail [preauth]
error: Received disconnect from 189.57.57.218: 3: com.jcraft.jsch.JSchException: Auth fail [preauth]
```

```
$ buildkite projects-status
NAME                              STATUS  BRANCH  URL
babelstoemp/operator              failed  master  https://buildkite.com/babelstoemp/operator
babelstoemp/ansible-playbook-dev  passed  master  https://buildkite.com/babelstoemp/ansible-playbook-dev
```
