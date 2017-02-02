package jib_test

import (
	"jib"
	"jib/github"
	"reflect"
	"testing"
)

func TestExtractCommands(t *testing.T) {
	cases := []struct {
		comments             []*github.IssueComment
		ignoredUsername      string
		expectedCommandNames []string
	}{
		{
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
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "/merge",
				},
			},
			expectedCommandNames: []string{"merge"},
		},
		{
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "Sounds good /merge",
				},
			},
			expectedCommandNames: []string{"merge"},
		},
		{
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "user",
					},
					Body: "Sounds good\n/merge",
				},
			},
			expectedCommandNames: []string{"merge"},
		},
		{
			comments: []*github.IssueComment{
				{
					User: &github.User{
						Login: "bot",
					},
					Body: "Please reissue your /merge command",
				},
			},
			ignoredUsername:      "bot",
			expectedCommandNames: []string{},
		},
	}

	for _, tc := range cases {
		commands := jib.ExtractCommands(tc.comments, []string{tc.ignoredUsername})
		commandNames := []string{}
		for _, command := range commands {
			commandNames = append(commandNames, command.Name)
		}

		if !reflect.DeepEqual(commandNames, tc.expectedCommandNames) {
			t.Errorf("expected %v, got %v", tc.expectedCommandNames, commandNames)
		}
	}
}
