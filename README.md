# Canoe

:ship: Canoe is the frontend that ships our code to production.

* Canoe Production: <https://canoe.pardot.com>
* Canoe Staging: <https://canoe.dev.pardot.com>

## Development Setup

Canoe uses GitHub style [scripts-to-rule-them-all](https://github.com/github/scripts-to-rule-them-all).

To install required gems and to setup the database:

```
script/setup
```

`script/setup` should only need to be run once. Use `script/update` in future after adding new gems or pulling new code.

### Secrets

Canoe uses the GitHub API to get information about branches, tags, etc. For local development, you can use your own user to authenticate against that API.

First, copy the `.envvars_sample.rb` file to `.envvars_development.rb`:

```
cp .envvars_sample.rb .envvars_development.rb
```

[Create a Personal Access Token](https://git.dev.pardot.com/settings/applications) and provide it as `GITHUB_PASSWORD` in `.envvars_development.rb`:

```
# .envvars_development.rb
ENV["GITHUB_USER"] = "my_ldap_username"
ENV["GITHUB_PASSWORD"] = "my_personal_access_token"
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
