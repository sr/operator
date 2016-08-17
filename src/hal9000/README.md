# HAL9000

Hal reincarnated as a Lita bot. Lita is stable, maintained, and written in Ruby.

## Development

HAL9000 encourages the use of [devenv](https://git.dev.pardot.com/Pardot/devenv). After installing devenv, run:

```bash
devenv compose up
```

* If you get an error like this while running locally:

```bash
ERROR: Service 'app' failed to build: Get https://docker.dev.pardot.com/v2/base/ruby/manifests/2.3.0: unauthorized: BAD_CREDENTIAL
```

* You may need to checkout [this confluence article](https://confluence.dev.pardot.com/display/PTechops/Using+the+Docker+Registry+locally)

In another shell, connect to the bot:

```bash
devenv compose run -e LITA_ADAPTER=shell app
```

You should be connect to an interactive session with Hal9000:

```
Type "exit" or "quit" to end the session.
Hal >
```

If everything worked, you can type `!help`:

```
Hal > !help
Hal: help - Lists help information for terms and command the robot will respond to.
```

### Tests

```bash
devenv compose run app script/test
```

### Handlers

Familiarize yourself with the [Plugin Authoring](http://docs.lita.io/plugin-authoring/) documentation.

#### New Handler

Checkout one the existing handlers under the `app/handlers` directory for
examples.
