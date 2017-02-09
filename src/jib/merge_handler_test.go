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
	developerUser := &github.User{
		Login: "pardot-developer",
	}
	sreUser := &github.User{
		Login: "site-reliability-engineer",
	}
	ciUser := &github.User{
		Login: jib.CIUserLogin,
	}

	cases := []struct {
		pullRequest          *github.PullRequest
		comments             []*github.IssueComment
		commitStatuses       map[string][]*github.CommitStatus
		commitsSince         map[string][]*github.Commit
		teamMembers          map[string][]string
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
					User: developerUser,
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
			commitsSince: map[string][]*github.Commit{
				"abc123": {},
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
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: developerUser,
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
			commitsSince: map[string][]*github.Commit{
				"abc123": {},
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &jib.MergeReplyCommentContext{
					InReplyToID: 123,
				},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@pardot-developer I can't merge.*because the pull request is not in a mergeable state.`),
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
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: developerUser,
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
			commitsSince: map[string][]*github.Commit{
				"abc123": {},
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
			comments: []*github.IssueComment{
				{
					ID:   123,
					User: developerUser,
					Body: "/merge",
				},
			},
			commitStatuses: map[string][]*github.CommitStatus{
				"abc123": {
					{
						Context: jib.ComplianceStatusContext,
						State:   github.CommitStatusFailure,
					},
				},
			},
			commitsSince: map[string][]*github.Commit{
				"abc123": {},
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &jib.MergeReplyCommentContext{
					InReplyToID: 123,
				},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@pardot-developer I can't merge.*because the compliance status check failed.`),
					regexp.MustCompile(`Please fix.*and re-issue the /merge command`),
				},
			},
			expectedToMerge: false,
		},
		// Mergable PR, but new commits after the /merge command issued
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
					ID:        123,
					User:      developerUser,
					Body:      "/merge",
					CreatedAt: time.Now().Add(-2 * time.Minute),
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
			commitsSince: map[string][]*github.Commit{
				"abc123": {
					{
						SHA:       "bcd345",
						Author:    developerUser,
						Committer: developerUser,
						Message:   "Fixes the thing",
					},
				},
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &jib.MergeReplyCommentContext{
					InReplyToID: 123,
				},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@pardot-developer I didn't merge this PR because there was a commit created since the /merge command was issued`),
				},
			},
			expectedToMerge: false,
		},
		// Mergable PR, only CI commits after the merge was issued
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
					ID:        123,
					User:      developerUser,
					Body:      "/merge",
					CreatedAt: time.Now().Add(-2 * time.Minute),
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
			commitsSince: map[string][]*github.Commit{
				"abc123": {
					{
						SHA:       "bcd345",
						Author:    ciUser,
						Committer: ciUser,
						Message:   "[ci] Automated branch merge (from master:ccc123)",
					},
				},
			},
			expectedToMerge: true,
		},
		// Emergency merge, tests pending
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
					ID:        123,
					User:      sreUser,
					Body:      "/emergency-merge",
					CreatedAt: time.Now().Add(-2 * time.Minute),
				},
			},
			commitStatuses: map[string][]*github.CommitStatus{
				"abc123": {
					{
						Context: jib.ComplianceStatusContext,
						State:   github.CommitStatusPending,
					},
				},
			},
			commitsSince: map[string][]*github.Commit{
				"abc123": {},
			},
			teamMembers: map[string][]string{
				"site-reliability-engineers": []string{sreUser.Login},
			},
			expectedToMerge: true,
		},
		// Emergency merge, not on an authorized team
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
					ID:        123,
					User:      developerUser,
					Body:      "/emergency-merge",
					CreatedAt: time.Now().Add(-2 * time.Minute),
				},
			},
			commitStatuses: map[string][]*github.CommitStatus{
				"abc123": {
					{
						Context: jib.ComplianceStatusContext,
						State:   github.CommitStatusPending,
					},
				},
			},
			commitsSince: map[string][]*github.Commit{
				"abc123": {},
			},
			teamMembers: map[string][]string{
				"developers": []string{developerUser.Login},
			},
			expectedReplyComment: &issueReplyCommentMatcher{
				Context: &jib.MergeReplyCommentContext{
					InReplyToID: 123,
				},
				BodyRegexps: []*regexp.Regexp{
					regexp.MustCompile(`@pardot-developer I didn't perform an emergency merge for this PR because you are not a member of one of the teams allowed to authorize emergency merges`),
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
			CommitsSince:   tc.commitsSince,
			TeamMembers:    tc.teamMembers,
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
