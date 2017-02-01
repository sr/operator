package jib

import (
	"jib/github"
	"testing"
)

func TestMergeCommandHandler(t *testing.T) {
	authorizedUser := &github.User{
		Login: "authorized-user",
	}

	cases := []struct {
		pullRequest     *github.PullRequest
		comments        []*github.IssueComment
		expectedToMerge bool
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
					User: authorizedUser,
					Body: "/merge",
				},
			},
			expectedToMerge: true,
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
					User: authorizedUser,
					Body: "/merge",
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
			t.Error(err)
		}

		_, merged := client.MergedPullRequests[tc.pullRequest.Number]
		if merged != tc.expectedToMerge {
			t.Errorf("expected merged = %v, but was %v", tc.expectedToMerge, merged)
		}
	}
}
