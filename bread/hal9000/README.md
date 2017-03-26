Hal reincarnated as a Lita bot. Lita is stable, maintained, and written in Ruby.

## Development

HAL9000 encourages the use of [devenv](https://git.dev.pardot.com/Pardot/devenv). After installing devenv, run:

```bash
cp .env_sample .env # edit .env if you wish to use real secrets
script/console
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
script/test
```

### Handlers

Familiarize yourself with the [Plugin Authoring](http://docs.lita.io/plugin-authoring/) documentation.
