# Pull request flow

## Table of contents

* [Overview](#overview)
* [As someone requesting a change](#as-someone-requesting-a-change)
* [As someone reviewing a change](#as-someone-reviewing-a-change)

## Overview

In order to allow for the normal [GitHub Pull Request Discussion][1] workflow, Changeling takes advantage of the GitHub API and [commit statuses][2] to let users know their changes require approval. This allows us to link units of work to approved changes.

When a new pull request is created, a Multipass is created. In Changeling, a Multipass tracks the metadata around a given change to a component. A Multipass starts its life in a failing status, reflected as a GitHub commit status context (looks like a failing Travis CI build). Once an appropriate stakeholder has answered a few questions in Changeling the little checkmark turns green and you can ship your compliant code to production.

If you have advice or suggestions as to how we can make this process even more pleasant
please do let us know.

## As someone requesting a change

Make your changes, and create a GitHub pull request as you normally would.

### Pull request created

This is what a pull request looks like when you first create one. Notice the failing commit status.

![](https://www.dropbox.com/s/2b6pixddxg19crm/Screenshot%202016-01-14%2015.38.54.png?dl=1)

### Entering Changeling

Clicking the Details link next to the failing status takes you to Changeling, where you can see a Multipass with defaults filled in.

![](https://www.dropbox.com/s/66a4my0srjfd35q/Screenshot%202016-01-14%2015.40.25.png?dl=1)

From here, other engineers can review and approve your request. Depending on the type of change, different buttons will be available.

Clicking the Pencil icon will take you to the edit page for the Multipass. It's the responsibility of the requester to choose an Impact and Impact Probability, and determine what type of change this is. The Change Type will automatically pre-select a type based on what is selected for your Impact and Impact Probability, but you can change it to override the suggestion.

![](https://www.dropbox.com/s/8sjglqkxiage5ie/Screenshot%202016-01-14%2015.53.12.png?dl=1)

The Tested checkbox will be automatically checked once it passes if you use Travis CI for your repository. If not, you'll want to take care of that yourself.

#### In case of emergency

If you're trying to ship something quickly for an emergency, you can use the Emergency Override button to bypass reviews and get the Multipass marked as passing on GitHub.

Be sure to return to Changeling after the emergency and get the proper reviews.

### After reviews/approvals

Once your Multipass is complete and all reviews or approvals are done, it'll turn green and you can ship your changes!

![](https://www.dropbox.com/s/vpu4zr0u0s6q64b/Screenshot%202016-01-14%2016.58.47.png?dl=1)

## As someone reviewing a change

If you're reviewing or approving a change, the requester can either give you a link to the change or the pull request in question. In most cases, engineers on a team will review each others' pull requests as normal, and see the failing Changeling commit status.

You can also find changes that need a review in the [Changeling dashboard](https://changeling.heroku.tools).

### From a pull request

To approve a change in a pull request, click the Details link next to the failing commit status.

![](https://www.dropbox.com/s/2b6pixddxg19crm/Screenshot%202016-01-14%2015.38.54.png?dl=1)

From here, you'll see a few buttons for approving the request. Click the approval you want to give, and you're done.

![](https://www.dropbox.com/s/66a4my0srjfd35q/Screenshot%202016-01-14%2015.40.25.png?dl=1)

Note: A Multipass is considered complete when all required fields are filled, and all approvals are met. Your approval may not be the final thing necessary to mark the Multipass complete, so you may not see the commit status turn green on the pull request once you've given your approval.

[1]: https://help.github.com/articles/using-pull-requests/#pull-request-discussion
[2]: https://developer.github.com/v3/repos/statuses/
