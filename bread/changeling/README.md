# Changeling [![Build Status](https://magnum.travis-ci.com/heroku/changeling.svg?token=sCaMa7HeG4812XfRVVH2)](https://magnum.travis-ci.com/heroku/changeling) [![Code Climate](https://codeclimate.com/repos/5642059769568009c700000d/badges/c65a4629b97284ce9464/gpa.svg)](https://codeclimate.com/repos/5642059769568009c700000d/feed) [![Test Coverage](https://codeclimate.com/repos/5642059769568009c700000d/badges/c65a4629b97284ce9464/coverage.svg)](https://codeclimate.com/repos/5642059769568009c700000d/coverage)

## About

Changeling tracks changes in production applications to achieve HIPAA/PCI/SOX compliance.

## Usage

Changeling integrates with GitHub like Travis CI. It creates a status on your PRs. When you create a PR your compliance status will be pending. Once you've filled out a quick form and had a someone review your code the status will turn green, and you can continue on your way to getting that change into a production environment.

To learn how to use Changeling, take a look at our workflow docs below.

* [Getting started](https://github.com/heroku/changeling/blob/master/doc/getting_started.md)
* [Usage](https://github.com/heroku/changeling/blob/master/doc/pull_request_flow.md)
* [FAQ](https://github.com/heroku/changeling/blob/master/doc/FAQ.md)
* [How we use Component Inventory](https://github.com/heroku/changeling/blob/master/doc/component-inventory.md)

## Adoption / usage metrics

* [Metrics dashboard](https://metrics.librato.com/s/spaces/119933?duration=2419200&source=com.heroku.metcollect.staging.%2a) - Statistics on how this tool is being adopted across the company, such as how many multipasses are being created and completed.

## Hacking

### Setup

```
$ bin/setup
```

### Testing

```
$ bin/cibuild
```

![doppelganger](https://cloud.githubusercontent.com/assets/270746/10918406/55870568-821a-11e5-9660-5b37829ac0d4.jpg)
