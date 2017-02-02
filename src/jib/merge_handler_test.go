package jib_test

import (
	"io/ioutil"
	"jib"
	"jib/github"
	"log"
	"regexp"
	"testing"
	"time"
)

func TestMergeCommandHandler(t *testing.T) {
	authorizedUser := &github.User{
		Login: "authorized-user",
	}

	cases := []struct {
		pullRequest          *github.PullRequest
		comments             []*github.IssueComment
		commitStatuses       map[string][]*github.CommitStatus
		expectedReplyComment *issueReplyCommentMatcher
		expectedToMerge      bool
	}{
		// Mergeable PR, command issued
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				Mergeable:  github.Bool(true),
				HeadSHA:    "abc123",
			},
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: authorizedUser,
					Body: "/merge",
				},
			},
			commitStatuses: map[string][]*github.CommitStatus{
				"abc123": {
					{
						Context: jib.ComplianceStatusContext,
						State:   github.CommitStatusSuccess,
					},
				},
			},
			expectedReplyComment: nil,
			expectedToMerge:      true,
		},
		// Unmergeable PR, command issued
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				Mergeable:  github.Bool(false),
				HeadSHA:    "abc123",
			},
			commitStatuses: map[string][]*github.CommitStatus{
				"abc123": {
					{
						Context: jib.ComplianceStatusContext,
						State:   github.CommitStatusSuccess,
					},
				},
			},
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: authorizedUser,
					Body: "/merge",
				},
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &jib.MergeReplyCommentContext{
					InReplyToID: 123,
				},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@authorized-user I can't merge.*because the pull request is not in a mergeable state.`),
					regexp.MustCompile(`Please fix.*and re-issue the /merge command`),
				},
			},
			expectedToMerge: false,
		},
		// Mergeability undetermined, command issued
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				Mergeable:  nil,
				HeadSHA:    "abc123",
			},
			commitStatuses: map[string][]*github.CommitStatus{
				"abc123": {
					{
						Context: jib.ComplianceStatusContext,
						State:   github.CommitStatusSuccess,
					},
				},
			},
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: authorizedUser,
					Body: "/merge",
				},
			},
			expectedReplyComment: nil,
			expectedToMerge:      false,
		},
		// Mergeable PR, but tests failed
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				Mergeable:  github.Bool(true),
				HeadSHA:    "abc123",
			},
			commitStatuses: map[string][]*github.CommitStatus{
				"abc123": {
					{
						Context: jib.ComplianceStatusContext,
						State:   github.CommitStatusFailure,
					},
				},
			},
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: authorizedUser,
					Body: "/merge",
				},
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &jib.MergeReplyCommentContext{
					InReplyToID: 123,
				},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@authorized-user I can't merge.*because the compliance status check failed.`),
					regexp.MustCompile(`Please fix.*and re-issue the /merge command`),
				},
			},
			expectedToMerge: false,
		},
		// Mergable PR, but updated after /merge command issued
		{
			pullRequest: &github.PullRequest{
				Org:        "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				Mergeable:  github.Bool(true),
				HeadSHA:    "abc123",
				UpdatedAt:  time.Now().Add(-1 * time.Minute),
			},
			commitStatuses: map[string][]*github.CommitStatus{
				"abc123": {
					{
						Context: jib.ComplianceStatusContext,
						State:   github.CommitStatusSuccess,
					},
				},
			},
			comments: []*github.IssueComment{
				{
					ID:        123,
					User:      authorizedUser,
					Body:      "/merge",
					CreatedAt: time.Now().Add(-2 * time.Minute),
				},
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &jib.MergeReplyCommentContext{
					InReplyToID: 123,
				},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@authorized-user I didn't merge this PR because it was updated after the /merge command was issued`),
				},
			},
			expectedToMerge: false,
		},
	}

	for _, tc := range cases {
		client := &github.FakeClient{
			OpenPullRequests: []*github.PullRequest{tc.pullRequest},
			IssueComments: map[int][]*github.IssueComment{
				tc.pullRequest.Number: tc.comments,
			},
			CommitStatuses: tc.commitStatuses,
		}
		log := log.New(ioutil.Discard, "", 0)

		err := jib.MergeCommandHandler(log, client, tc.pullRequest)
		if err != nil {
			t.Fatal(err)
		}

		_, merged := client.MergedPullRequests[tc.pullRequest.Number]
		if merged != tc.expectedToMerge {
			t.Fatalf("expected merged = %v, but was %v", tc.expectedToMerge, merged)
		}

		if tc.expectedReplyComment != nil {
			if len(client.PostedComments) != 1 {
				t.Fatalf("expected 1 comment to be posted, but were %d\n", len(client.PostedComments))
			}

			err = assertIssueReplyMatches(tc.expectedReplyComment, client.PostedComments[0])
			if err != nil {
				t.Fatal(err)
			}
		} else if len(client.PostedComments) != 0 {
			t.Fatalf("expected 0 comments to be posted, but were %d\n", len(client.PostedComments))
		}
	}
}
