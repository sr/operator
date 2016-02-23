# Canoe

:ship: Canoe is the frontend that ships our code to production.

* Canoe Production: <https://canoe.pardot.com>
* Canoe Staging: <https://canoe.dev.pardot.com>

## Development Setup

Canoe encourages the use of [devenv](https://git.dev.pardot.com/Pardot/devenv). After installing devenv, run:

```bash
devenv compose up
```

Then nativate to <http://localhost:4000> in your browser.

### Secrets

Canoe uses the GitHub API to get information about branches, tags, etc. For local development, you can use your own user to authenticate against that API.

First, copy the `.envvars_sample.rb` file to `.envvars_development.rb`:

```
cp .envvars_sample.rb .envvars_development.rb
```

Generate some secrets:
* [Create a Personal Access Token](https://git.dev.pardot.com/settings/applications) and provide it as `GITHUB_PASSWORD`.
* [Create an Artifactory API Token](https://artifactory.dev.pardot.com/artifactory/webapp/#/profile) and provide it as `ARTIFACTORY_API_KEY`.

```
# .envvars_development.rb
ENV["GITHUB_USER"] = "my_ldap_username"
ENV["GITHUB_PASSWORD"] = "my_personal_access_token"

ENV["ARTIFACTORY_USERNAME"] = "my_ldap_username"
ENV["ARTIFACTORY_API_KEY"] = "my_api_key"
```

### Tests

```bash
devenv compose run app script/test
```

Run specific tests:

```
devenv compose run app script/test spec/path/to/whatever_spec.rb
```

### Updating a Gem

Bump the gem in `Gemfile`, then run:

```bash
devenv compose run app script/update
```

## Production Setup

### Background

Canoe is deployed to Amazon Web Services. We run it outside of our datacenters for now to improve its resiliency in the case of a failover.

Specifically, Canoe is deployed by running a Docker image (built on Bamboo and pushed to AWS Container Registry) via Elastic Container Service on the `pardotops` AWS account.

The steps for deployment are:

1. Merge code to master
1. Wait for Bamboo to build and test Canoe
1. Deploy Canoe via the Bamboo user interface
