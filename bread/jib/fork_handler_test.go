package jib_test

import (
	"io/ioutil"
	"log"
	"regexp"
	"testing"

	"git.dev.pardot.com/Pardot/infrastructure/bread/jib"
	"git.dev.pardot.com/Pardot/infrastructure/bread/jib/github"
)

func TestForkHandler(t *testing.T) {
	user := &github.User{
		Login: "user",
	}

	cases := []struct {
		pullRequest          *github.PullRequest
		expectedReplyComment *issueReplyCommentMatcher
		expectedToClose      bool
	}{
		// PR with the same head user as base user. Should not be closed.
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				User:       user,
				HeadUser:   "foo",
				BaseUser:   "foo",
			},
			expectedToClose: false,
		},
		// PR with a different head user as base user. Should be closed.
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				User:       user,
				HeadUser:   "foo",
				BaseUser:   "bar",
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: struct{}{},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@user.*pull requests originating from forked repositories are not allowed`),
					regexp.MustCompile(`reopen the pull request against that branch`),
				},
			},
			expectedToClose: true,
		},
	}

	for _, tc := range cases {
		client := &github.FakeClient{
			OpenPullRequests: []*github.PullRequest{tc.pullRequest},
		}
		log := log.New(ioutil.Discard, "", 0)
		jiber := jib.New(log, client, &jib.Config{})

		if err := jiber.Fork(tc.pullRequest); err != nil {
			t.Fatal(err)
		}

		if tc.expectedToClose {
			if len(client.ClosedIssues) != 1 {
				t.Fatalf("expected to close 1 issue, but %d were closed", len(client.ClosedIssues))
			}
			if client.ClosedIssues[0] != tc.pullRequest.Number {
				t.Fatalf("expected to close issue number %d, but was %d", tc.pullRequest.Number, client.ClosedIssues[0])
			}
		} else if len(client.ClosedIssues) != 0 {
			t.Fatalf("expected to close 0 issues, but %d were closed", len(client.ClosedIssues))

		}

		if tc.expectedReplyComment != nil {
			if len(client.PostedComments) != 1 {
				t.Fatalf("expected 1 comment to be posted, but %d were posted", len(client.PostedComments))
			}

			if err := assertIssueReplyMatches(tc.expectedReplyComment, client.PostedComments[0]); err != nil {
				t.Fatal(err)
			}
		} else if len(client.PostedComments) != 0 {
			t.Fatalf("expected 0 comments to be posted, but %d were posted", len(client.PostedComments))
		}
	}
}
