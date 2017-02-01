package jib

import (
	"jib/github"
	"reflect"
	"testing"
)

func TestExtractCommands(t *testing.T) {
	cases := []struct {
		comments             []*github.IssueComment
		expectedCommandNames []string
	}{
		{
			comments: []*github.IssueComment{
				{
					Body: "",
				},
			},
			expectedCommandNames: []string{},
		},
		{
			comments: []*github.IssueComment{
				{
					Body: "/merge",
				},
			},
			expectedCommandNames: []string{"merge"},
		},
		{
			comments: []*github.IssueComment{
				{
					Body: "Sounds good /merge",
				},
			},
			expectedCommandNames: []string{"merge"},
		},
		{
			comments: []*github.IssueComment{
				{
					Body: "Sounds good\n/merge",
				},
			},
			expectedCommandNames: []string{"merge"},
		},
	}

	for _, tc := range cases {
		commands := ExtractCommands(tc.comments)
		commandNames := []string{}
		for _, command := range commands {
			commandNames = append(commandNames, command.Name)
		}

		if !reflect.DeepEqual(commandNames, tc.expectedCommandNames) {
			t.Errorf("expected %v, got %v", tc.expectedCommandNames, commandNames)
		}
	}
}
