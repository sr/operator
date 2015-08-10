# Canoe

:ship: Canoe is the frontend that ships our code to production.

* Canoe Production: <https://canoe.pardot.com>
* Canoe Staging: <https://canoe.pardot.com>

## Development Setup

Canoe uses GitHub style [scripts-to-rule-them-all](https://github.com/github/scripts-to-rule-them-all).

To install required gems and to setup the database:

```
script/setup
```

`script/setup` should only need to be run once. Use `script/update` in future after adding new gems or pulling new code.

### Secrets

Canoe uses the GitHub API to get information about branches, tags, etc. For local development, you can use your own user to authenticate against that API.

First, copy the `.env.sample` file to `.env`:

```
cp .env.sample .env
```

[Create a Personal Access Token](https://git.dev.pardot.com/settings/applications) and provide it as `GITHUB_PASSWORD` in `.env`:

```
# .env
GITHUB_USER=my_ldap_username
GITHUB_PASSWORD=my_personal_access_token
```

### Tests

Run all the tests:

```
script/test
```

Run specific tests:

```
script/test spec/path/to/whatever_spec.rb
```
