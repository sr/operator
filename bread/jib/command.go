package jib

import (
	"fmt"
	"regexp"
	"strings"
	"time"

	"git.dev.pardot.com/Pardot/infrastructure/bread/jib/github"
)

var (
	cmdRe = regexp.MustCompile(`(?m)(?:^|\s)/(\S+)(?:\s+([^/]\S*))*`)
)

// Command is a representation of a slash command in a GitHub pull request.
//
// For example, &Command{Name: "automerge"} represents someone issuing the
// "/automerge" command in a pull-request comment
type Command struct {
	Name    string
	Comment *CommandComment
}

type CommandComment struct {
	ID        int
	User      *github.User
	Body      string
	CreatedAt time.Time
}

func (c *Command) String() string {
	return fmt.Sprintf("/%s", c.Name)
}

// ExtractCommands extracts commands from the list of comments.
//
// It ignores any comments from ignoredUsernames, so that bots don't end up talking to themselves.
func ExtractCommands(pr *github.PullRequest, comments []*github.IssueComment, ignoredUsernames []string) []*Command {
	commands := []*Command{}

	allComments := []*CommandComment{
		{
			ID:        0,
			User:      pr.User,
			Body:      pr.Body,
			CreatedAt: pr.CreatedAt,
		},
	}

	// Combine PR body with all comments
	for _, comment := range comments {
		allComments = append(allComments, &CommandComment{

			ID:        comment.ID,
			User:      comment.User,
			Body:      comment.Body,
			CreatedAt: comment.CreatedAt,
		})
	}

	for _, comment := range allComments {
		ignored := false
		for _, ignoredUsername := range ignoredUsernames {
			if ignoredUsername == comment.User.Login {
				ignored = true
				break
			}
		}

		if !ignored {
			matches := cmdRe.FindAllStringSubmatch(comment.Body, -1)
			for _, matches := range matches {
				commands = append(commands, &Command{
					Name:    strings.ToLower(matches[1]),
					Comment: comment,
				})
			}
		}
	}
	return commands
}
