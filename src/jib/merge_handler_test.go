package jib

import (
	"jib/github"
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
		expectedReplyComment *issueReplyCommentMatcher
		expectedToMerge      bool
	}{
		// Mergeable PR, command issued
		{
			pullRequest: &github.PullRequest{
				Owner:      "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				Mergeable:  github.Bool(true),
			},
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: authorizedUser,
					Body: "/merge",
				},
			},
			expectedReplyComment: nil,
			expectedToMerge:      true,
		},
		// Unmergeable PR, command issued
		{
			pullRequest: &github.PullRequest{
				Owner:      "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				Mergeable:  github.Bool(false),
			},
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: authorizedUser,
					Body: "/merge",
				},
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &mergeReplyCommentContext{
					InReplyToID: 123,
				},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@authorized-user I can't merge.*because a required status failed`),
					regexp.MustCompile(`Please fix.*and re-issue the /merge command`),
				},
			},
			expectedToMerge: false,
		},
		// Mergable PR, but updated after /merge command issued
		{
			pullRequest: &github.PullRequest{
				Owner:      "pardot",
				Repository: "bread",
				Number:     1,
				State:      "open",
				Mergeable:  github.Bool(true),
				UpdatedAt:  time.Now().Add(-1 * time.Minute),
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
				Context: &mergeReplyCommentContext{
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
		}

		err := MergeCommandHandler(client, tc.pullRequest)
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

			err = tc.expectedReplyComment.AssertMatches(client.PostedComments[0])
			if err != nil {
				t.Fatal(err)
			}
		} else if len(client.PostedComments) != 0 {
			t.Fatalf("expected 0 comments to be posted, but were %d\n", len(client.PostedComments))
		}
	}
}
