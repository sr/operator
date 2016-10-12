# HAL9000

Hal reincarnated as a Lita bot. Lita is stable, maintained, and written in Ruby.

## Development

HAL9000 encourages the use of [devenv](https://git.dev.pardot.com/Pardot/devenv). After installing devenv, run this command to get an interactive session:

```bash
script/console
```

If everything worked, you can type `!info`:

```
$ script/console
Type "exit" or "quit" to end the session.
HAL9000 > !info
[2016-10-12 17:31:47 UTC] DEBUG: Dispatching message to Lita::Handlers::Info#chat.
Lita 4.7.0 - https://www.lita.io/
Redis 2.6.17 - Memory used: 837.19K
```

**NOTE:** If you get an error like this:

```
ERROR: Service 'app' failed to build: Get https://docker.dev.pardot.com/v2/base/ruby/manifests/2.3.0: unauthorized: BAD_CREDENTIAL
```

You may need to checkout [this page on Confluence](https://confluence.dev.pardot.com/display/PTechops/Using+the+Docker+Registry+locally)

### Tests

```bash
devenv compose run app script/test
```

### Handlers

Familiarize yourself with the [Plugin Authoring](http://docs.lita.io/plugin-authoring/) documentation.

#### New Handler

Checkout one the existing handlers under the `app/handlers` directory for
examples.
