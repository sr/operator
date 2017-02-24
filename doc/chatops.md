# Chat bots and ChatOps

Whether you're to looking to expose complex production workflows through chat or simply share quality GIFs, the BREAD team wants to help. We maintain the HAL9000 chat bot and welcome all contributions.

## Implementing a chat command for HAL9000

HAL9000 is built on top of the  [Lita](https://www.lita.io/) framework, and commands are written in Ruby. There are hundreds of existing community plugins which are generally of good quality.  We suggest checking out the plugins catalog before going any further:

<https://plugins.lita.io/#handlers>

To install a plugin, add it to HAL9000's [Gemfile](https://git.dev.pardot.com/Pardot/bread/blob/master/src/hal9000/Gemfile), run `bundler update`, and create a pull request.

If none of the existing plugins fit your needs, the fastest way to get started is to read the code of one of the existing handlers:

https://git.dev.pardot.com/Pardot/bread/blob/master/src/hal9000/app/handlers/commit_handler.rb
https://git.dev.pardot.com/Pardot/bread/blob/master/src/hal9000/spec/handlers/commit_handler_spec.rb

The official Lita documentation is great and should cover everything needed for implementing new chat commands:

* [Defining chat routes](https://docs.lita.io/plugin-authoring/handlers/#chat-routes)
* [Helper methods](https://docs.lita.io/plugin-authoring/handlers/#helper-methods)
* [Configuration](https://docs.lita.io/plugin-authoring/handlers/#configuration)

We highly recommend that new HAL9000 commands come with at least one happy-path test case. This helps us maintain and support  commands in the long term, making sure they keeps working for years to come. Checkout the [testing guide](https://docs.lita.io/plugin-authoring/testing/#testing-handlers) for in depth documentation or one of the existing test cases for examples:

https://git.dev.pardot.com/Pardot/bread/tree/master/src/hal9000/spec/handlers

### Running HAL9000 locally

HAL9000 requires [devenv](https://git.dev.pardot.com/Pardot/bread/tree/master). After installing devenv, move into the hal9000 root directory:

`$ cd src/hal9000`

Then run this command to get an interactive session:

`$ script/console`

If everything worked, you should be able to type `!info` and get a reply from HAL90000:

```
$ script/console
Type "exit" or "quit" to end the session.
HAL9000 > !info
[2016-10-12 17:31:47 UTC] DEBUG: Dispatching message to Lita::Handlers::Info#chat.
Lita 4.7.0 - https://www.lita.io/
Redis 2.6.17 - Memory used: 837.19K`
```

**NOTE:** If you get an error like this:

```
ERROR: Service 'app' failed to build: Get https://docker.dev.pardot.com/v2/base/ruby/manifests/2.3.0: unauthorized: BAD_CREDENTIAL
```

Checkout [this page on Confluence](https://confluence.dev.pardot.com/display/PTechops/Using+the+Docker+Registry+locally) for help. It means your docker client has not been setup properly.

Run the tests using the `script/test` command.

### Deployment

[Open a pull request](https://help.github.com/articles/creating-a-pull-request/) on the BREAD repo and, get reviewed it and approved, then use the `!deploy` command to deploy your branch:

```
!deploy trigger target=hal9000 branch=my-great-branch
```

Confirm everything is working as expected, then merge your branch. Otherwise rollback to master, fix your branch, and repeat the process until you are satisfied with your changes and HAL9000 is in a good state.

## Implementing chat commands as gRPC methods

We also support implementing chat commands as  [gRPC](http://www.grpc.io/) methods. This biggest difference with those implemented as Lita handlers  is the invocation syntax. Since they directly map to RPC (Remote Procedure Call) methods, commands always take the `service method [arg1=value]` form. This constraint may not be appropriate for all use cases.

Additionally, access to commands implemented this way is authorized based on LDAP group membership and allows to require 2FA (Two-factor Authentication) where needed. The ACL (Access Control List) is defined as code here:

<https://git.dev.pardot.com/Pardot/bread/blob/master/bread.go#L35>

Note that commands implemented this way must be written in [Go](https://golang.org/), a statically compiled language. We may add support for other languages such as Java in the future.

Documentation is rather sparse at this time, and reading the code is the best we have. The implementation of the `!deploy` command is a good starting point:

<https://git.dev.pardot.com/Pardot/bread/blob/master/pb/deploy.proto>
<https://git.dev.pardot.com/Pardot/bread/blob/master/deploy.go>

We also recommend reading `godoc ./`.

### Running the chatops server locally

The gRPC server that exposes chatops commands is part of the `operatord` command.  Building it requires installing the Go toolchain. On a macOS machine this should be as easy as running `brew install go`. Otherwise checkout the [official install documentation](https://golang.org/doc/install) for help.

To build the client and server, run:

`$ go install -v ./cmd/...`

If everything worked you should be able to run a development server like so:

````
$ operatord -dev
2016-10-19T08:32:45Z INFO bread.ServerStartupNotice {"Address":":9000","Protocol":"grpc","services":["bread.Deploy","bread.Ping"]}
2016-10-19T08:32:45Z INFO bread.ServerStartupNotice {"Address":":8080","Protocol":"http"}
```

In another shell use the `operatorctl` command to interact with the server:

```
$ operatorctl ping ping
pong
```

Rich HTML-formatted messages are sent to the [BREAD Testing](hipchat://hipchat.dev.pardot.com/room/882) room on HipChat.

Use the normal Go tooling to run the tests:

`$ go test -v ./...`

To run the entire battery of tests, including various lint checks and whatnot, run:

`$ make -f etc/mk/golang.mk`

This is what gets run on CI.

### Adding new RPC methods

All RPC services and their methods are defined in the protobuf files located in the `src/bread/pb` directory:

<https://git.dev.pardot.com/Pardot/bread/tree/master/src/bread/pb>

The implementation for the various services lives under the `bread` Go package. After changing the protobuf files be sure to update the generated code (including `operatorctl`) by running the fellowing command:

`$ tools/protogen`

## Par Bot

Par Bot has served us well but we have found it difficult to maintain and keep stable, and therefore have decided to deprecate it. We still accept bug fixes and minor contributions, but please implement all new commands in HAL9000 going forward. We will be migrating existing commands over to HAL9000 in the coming months. 

Par Bot is part of the BREAD repository:

[https://git.dev.pardot.com/Pardot/bread/tree/master/parbot#README](https://git.dev.pardot.com/Pardot/bread/tree/master/parbot)
