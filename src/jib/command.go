package jib

import (
	"jib/github"
	"regexp"
)

var (
	cmdRe = regexp.MustCompile(`(?:\s|\A)/(\S+)(?:\s|\z)`)
)

// Command is a representation of a slash command in a GitHub pull request.
//
// For example, &Command{Name: "merge"} represents someone issuing the "/merge"
// command in a pull-request comment
type Command struct {
	Name    string
	Comment *github.IssueComment
}

// ExtractCommands extracts commands from the list of comments.
//
// It ignores any comments from ignoredUsernames, so that bots don't end up talking to themselves.
func ExtractCommands(comments []*github.IssueComment, ignoredUsernames []string) []*Command {
	commands := []*Command{}
	for _, comment := range comments {
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
					Name:    matches[1],
					Comment: comment,
				})
			}
		}
	}
	return commands
}
