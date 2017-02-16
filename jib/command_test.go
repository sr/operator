package jib_test

import (
	"reflect"
	"testing"

	"git.dev.pardot.com/Pardot/bread/jib/github"

	"git.dev.pardot.com/Pardot/bread/jib"
)

func TestExtractCommands(t *testing.T) {
	cases := []struct {
		pr                   *github.PullRequest
		comments             []*github.IssueComment
		ignoredUsername      string
		expectedCommandNames []string
	}{
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "user",
				},
				Body: "",
			},
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "",
				},
			},
			expectedCommandNames: []string{},
		},
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "user",
				},
				Body: "",
			},
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "/automerge",
				},
			},
			expectedCommandNames: []string{"automerge"},
		},
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "user",
				},
				Body: "",
			},
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "/autoMerge",
				},
			},
			expectedCommandNames: []string{"automerge"},
		},
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "user",
				},
				Body: "",
			},
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "Sounds good /automerge",
				},
			},
			expectedCommandNames: []string{"automerge"},
		},
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "user",
				},
				Body: "",
			},
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "Sounds good /automerge /resolve",
				},
			},
			expectedCommandNames: []string{"automerge", "resolve"},
		},
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "user",
				},
				Body: "",
			},
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "Sounds good\n/automerge",
				},
			},
			expectedCommandNames: []string{"automerge"},
		},
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "user",
				},
				Body: "",
			},
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "bot",
					},
					Body: "/automerge",
				},
			},
			ignoredUsername:      "bot",
			expectedCommandNames: []string{},
		},
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "user",
				},
				Body: "/automerge",
			},
			comments:             []*github.IssueComment{},
			ignoredUsername:      "bot",
			expectedCommandNames: []string{"automerge"},
		},
		{
			pr: &github.PullRequest{
				User: &github.User{
					Login: "bot",
				},
				Body: "/automerge",
			},
			comments:             []*github.IssueComment{},
			ignoredUsername:      "bot",
			expectedCommandNames: []string{},
		},
	}

	for _, tc := range cases {
		commands := jib.ExtractCommands(tc.pr, tc.comments, []string{tc.ignoredUsername})
		commandNames := []string{}
		for _, command := range commands {
			commandNames = append(commandNames, command.Name)
		}

		if !reflect.DeepEqual(commandNames, tc.expectedCommandNames) {
			t.Errorf("expected %v, got %v for %#v", tc.expectedCommandNames, commandNames, tc)
		}
	}
}
