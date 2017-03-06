# Changeling FAQ

* [What does peer review really mean?][1]
* [I'm not in scope for HIPAA or PCI, do I have to use change control?][9]
* [What about open source dependencies?][4]
* [What about public repos?][2]
* [My pull requests are not showing up][3]
* [Can I approve via GitHub comments][8]
* [My repository doesn't have tests][6]


### What does peer review really mean?

Peer review is the same thing you've been doing with pull requests for years. Changeling is formalizing the required documentation that we need for HIPAA/PCI/SOX compliance.

> Yes, I understand the inherent risk associated with the changes introduced in this pull request and I'm ok with them.

### I'm not in scope for HIPAA or PCI, do I have to use change control?

There are some HIPAA and PCI requirements that apply uniformly across all production applications in an organization, and change control is one of them. Another example is vulnerability management - every system needs to be patching, even if it's not storing customer data.

### What about open source dependencies?

It is not necessary for Heroku employees to review all of the changes that they rely on from the open source community. We expect developers to use their best judgement and follow standard practices for versioning open source libraries and tools. When internal Heroku applications upgrade or downgrade versions of dependent software it's up to the team involved to define the scope of the peer review.

##### Nokogiri CVE Example

A CVE gets issued for the nokogiri gem that requires an update to the version of libxml2 that it bundles. Another recent CVE for a buffer overflow in libxml2 is the driving force behind the gem upgrade, but am I really qualified to review the latest version of libxml2 and sign off on the changes? It depends, but approval can take the form of common sense here because the maintainer issued a CVE and advised you to update.

##### Rollbar Gem Example

The banner at the top of your rollbar UI tells you that there is a new version of of the rollbar gem. It takes up space and it's annoying so you go to upgrade rollbar in your Gemfile. The update moves the rollbar gem version from '2.8.0' to '2.8.2'. Since the rollbar gem is hosted on GitHub we can create a compare URL to display the changes in our PR that bumps the version, https://github.com/rollbar/rollbar-gem/compare/v2.8.0...v2.8.2. In this case it's up to the proposer and the reviewer to decide on the level of scrutiny.

### What about public repos?

Changeling works with public repos. We only allow Heroku employees to sign off on changes though.

### My pull requests aren't showing up

You need to sign in to changeling in order for it to start interacting with the GitHub API on your behalf.

### My repository doesn't have tests

Your best bet is to setup and [empty test suite][7] and use travis. Otherwise you will need to click edit on the form each time and manually click the tested box.

### Can I approve via GitHub comments?

You can approve GitHub comments with the following emojis as long as they are at the beginning or end of your comment. While we understand that teams may want a wider range of emojis we need to limit it to just a few. We feel that these characters sufficiently cover approval.

#### Accepted Emoji
  * "👍", "👍🏻", "👍🏼", "👍🏽", "👍🏾", "👍🏿",
  * `:+1:`
  * "+1"
  * `:shipit:`
  * "lgtm"
  * "looks good to me"

#### Why does it need to be at the beginning or the end of my comment?

Having it at the beginning, let's us do something like:

> I can only +1 this if ...

Without accidentally validating it.

[1]: #what-does-peer-review-really-mean
[9]: #im-not-in-scope-for-hipaa-or-pci-do-i-have-to-use-change-control
[2]: #what-about-public-repos
[3]: #my-pull-requests-arent-showing-up
[4]: #what-about-open-source-dependencies
[6]: #my-repository-doesnt-have-tests
[7]: https://github.com/heroku/direwolf-tests/commit/d6c467c1d63a5d766af4b4296d00b02acbe21dd4
[8]: #can-i-approve-via-github-comments
