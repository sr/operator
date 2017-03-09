# PagerDuty::ChefServer::Sync

This gem provides a Knife plugin (`knife pd sync`) which supports the PagerDuty Chef workflow.

## PagerDuty Chef Workflow

PagerDuty uses a monolithic Chef repo, and does not bother with cookbook versioning. Instead, every time we make a change to our Chef repo, we delete all changed cookbooks and re-upload them, maintaining parity between our Git repo and Chef server. There are many reasons that we have adopted this workflow, though I'm too lazy to stroll through memory lane at the moment. You can learn more about it [here][1].

This plugin supports the aforementioned workflow. It integrates directly with Berkshelf. Invoking this plugin will:
* Run berks vendor
* Pull cookbook manifest from Chef server
* Look for local changes
* Loop through all changed cookbooks, first deleting all versions of it on Chef server, then uploading the version on disk
* Upload all data bags
* Upload all environments
* Upload all roles

## Installation

Simply include this gem in the Gemfile in your Chef repo:
```
gem 'pagerduty-pd_sync'
```

## Usage

```
knife pd sync
```

## License
[Apache 2](http://www.apache.org/licenses/LICENSE-2.0)

## Contributing

1. Fork it ( https://github.com/PagerDuty/pd-sync-chef/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[1]: https://www.pagerduty.com/blog/chef-at-pagerduty/
