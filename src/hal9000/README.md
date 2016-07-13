# HAL9000

Hal reincarnated as a Lita bot. Lita is stable, maintained, and written in Ruby.

## Development

HAL9000 encourages the use of [devenv](https://git.dev.pardot.com/Pardot/devenv). After installing devenv, run:

```bash
devenv compose up
```

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
devenv compose run app make test

# Or a specific plugin test
devenv compose run app make test-plugin-lita-replication-fixing
```

### Handlers

Familiarize yourself with the [Plugin Authoring](http://docs.lita.io/plugin-authoring/) documentation.

#### New Handler

Create the handler:

```bash
# Creates a handler named replication-fixing
devenv compose run app lita handler replication-fixing
mv lita-replication-fixing/ plugins/
```

Add it to `Gemfile`:

```ruby
gem "lita-replication-fixing", path: "plugins/lita-replication-fixing"
```

Add a `COPY` directive to `Dockerfile` that eagerly copies in the `Gemfile` and `.gemspec` file from the new plugin:

```
COPY plugins/lita-replication-fixing/*.gemspec plugins/lita-replication-fixing/Gemfile* /app/plugins/lita-replication-fixing/
```

Lock the dependency:

```bash
devenv compose build
```
