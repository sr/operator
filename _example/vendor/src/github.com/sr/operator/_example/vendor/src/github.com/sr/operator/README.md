Operator
========

**NOTE:** The documentation might be outdated as things are still very much in
flux. Please ping @sr for help.

Welcome to Operator. There is not much documentation at the moment. Please
checkout the [Quick Start](/doc/quick-start.md) and [Local Development][lo]
guides to get started.

[lo]: /doc/local-development.md

## Usage

```
$ operatorc src/services/**/*.proto \
        --server_out=~/bin/operatord \
        --hubot_out=~/src/travis/hubot/scripts \
        --cmd_out=~/bin/operator
```
