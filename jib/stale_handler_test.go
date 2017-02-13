package jib_test

import (
	"io/ioutil"
	"log"
	"regexp"
	"testing"
	"time"

	"git.dev.pardot.com/Pardot/bread/jib/github"

	"git.dev.pardot.com/Pardot/bread/jib"
)

func TestStaleHandler(t *testing.T) {
	user := &github.User{
		Login: "user",
	}

	cases := []struct {
		pullRequest          *github.PullRequest
		expectedReplyComment *issueReplyCommentMatcher
		expectedToClose      bool
	}{
		// PR 1 day before being stale. Should not be closed.
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				User:       user,
				UpdatedAt:  time.Now().Add(-59 * 24 * time.Hour),
			},
			expectedToClose: false,
		},
		// PR 1 day after being stale. Should be closed.
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				User:       user,
				UpdatedAt:  time.Now().Add(-61 * 24 * time.Hour),
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &jib.StaleReplyCommentContext{},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@user.*I have started automatically closing`),
					regexp.MustCompile(`Please feel free to reopen`),
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

		err := jib.StaleHandler(log, client, tc.pullRequest)
		if err != nil {
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

			err = assertIssueReplyMatches(tc.expectedReplyComment, client.PostedComments[0])
			if err != nil {
				t.Fatal(err)
			}
		} else if len(client.PostedComments) != 0 {
			t.Fatalf("expected 0 comments to be posted, but %d were posted", len(client.PostedComments))
		}
	}
}
