# Parbot

Parbot is our useful, but not production-critical chatbot. If you're looking for
our production-critical chatops bot, head over to
[hal](https://git.dev.pardot.com/Pardot/hal).

Parbot is built on the [hubot](http://hubot.github.com) framework.

## Development

Install `node` and `npm`. If you're on OS X and use Homebrew, this is basically:

```
brew install node4-lts
```

Install `mysql`:

```
brew install mysql
```

From here, we use GitHub style
[scripts-to-rule-them-all](https://github.com/github/scripts-to-rule-them-all):

To install dependencies:

```
script/bootstrap
```

To run the bot locally:

```
# run the bot locally
script/server
```

You'll see some start up output and a prompt:

```
[Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
Parbot>
```

Then you can interact with Parbot by typing `Parbot help`.

```
Parbot> Parbot help
Parbot animate me <query> - The same thing as `image me`, except adds [snip]
Parbot help - Displays all of the help commands that Parbot knows about.
...
```

## Configuration

A few scripts (including some installed by default) require environment
variables to be set as a simple form of configuration.

Each script should have a commented header which contains a "Configuration"
section that explains which values it requires to be placed in which variable.
When you have lots of scripts installed this process can be quite labour
intensive. The following shell command can be used as a stop gap until an
easier way to do this has been implemented.

    grep -o 'hubot-[a-z0-9_-]\+' external-scripts.json | \
      xargs -n1 -I {} sh -c 'sed -n "/^# Configuration/,/^#$/ s/^/{} /p" \
          $(find node_modules/{}/ -name "*.coffee")' | \
        awk -F '#' '{ printf "%-25s %s\n", $1, $2 }'

How to set environment variables will be specific to your operating system.
Rather than recreate the various methods and best practices in achieving this,
it's suggested that you search for a dedicated guide focused on your OS.

## Scripting

An example script is included at `scripts/example.coffee`, so check it out to
get started, along with the [Scripting Guide](scripting-docs).

For many common tasks, there's a good chance someone has already one to do just
the thing.

[scripting-docs]: https://github.com/github/hubot/blob/master/docs/scripting.md

### external-scripts

There will inevitably be functionality that everyone will want. Instead of
writing it yourself, you can use existing plugins.

Hubot is able to load plugins from third-party `npm` packages. This is the
recommended way to add functionality to your hubot. You can get a list of
available hubot plugins on [npmjs.com](npmjs) or by using `npm search`:

    % npm search hubot-scripts panda
    NAME             DESCRIPTION                        AUTHOR DATE       VERSION KEYWORDS
    hubot-pandapanda a hubot script for panda responses =missu 2014-11-30 0.9.2   hubot hubot-scripts panda
    ...


To use a package, check the package's documentation, but in general it is:

1. Use `npm install --save` to add the package to `package.json` and install it
2. Add the package name to `external-scripts.json` as a double quoted string

You can review `external-scripts.json` to see what is included by default.

##### Advanced Usage

It is also possible to define `external-scripts.json` as an object to
explicitly specify which scripts from a package should be included. The example
below, for example, will only activate two of the six available scripts inside
the `hubot-fun` plugin, but all four of those in `hubot-auto-deploy`.

```json
{
  "hubot-fun": [
    "crazy",
    "thanks"
  ],
  "hubot-auto-deploy": "*"
}
```

**Be aware that not all plugins support this usage and will typically fallback
to including all scripts.**

[npmjs]: https://www.npmjs.com

### hubot-scripts

Before hubot plugin packages were adopted, most plugins were held in the
[hubot-scripts][hubot-scripts] package. Some of these plugins have yet to be
migrated to their own packages. They can still be used but the setup is a bit
different.

To enable scripts from the hubot-scripts package, add the script name with
extension as a double quoted string to the `hubot-scripts.json` file in this
repo.

[hubot-scripts]: https://github.com/github/hubot-scripts

### Running Quotes DB Locally

Start up the mysql instance inside the parbot directory

```
mysql.server start
```

If you don't see the `parbot_development` database in mysql try editing `DATABASE_URL` in `.env` to:

```
DATABASE_URL="mysql://root:@localhost/parbot_development?socketPath=/tmp/mysql.sock&multipleStatements=true"
```

Then update and migrate:

```
script/update
script/migrate
```


