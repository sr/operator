package jib

import (
	"bytes"
	"fmt"
	"html/template"
	"jib/github"
	"log"
	"strings"
)

type mergeReplyCommentContext struct {
	InReplyToID int
}

var (
	unmergablePrReplyComment = template.Must(template.New("unmergeablePrReplyComment").Parse(strings.TrimSpace(`
@{{.User.Login}} I can't merge this PR right now because a required status failed.

Please fix the issue and re-issue the /merge command if you want.
`)))
)

func MergeCommandHandler(gh github.Client, pr *github.PullRequest) error {
	if pr.Mergeable == nil {
		log.Printf("pull request '%s' has undetermined mergeability, skipping for now", pr)
		return nil
	}

	comments, err := gh.GetIssueComments(pr.Owner, pr.Repository, pr.Number)
	if err != nil {
		return err
	}

	commands := ExtractCommands(comments)
	for _, command := range commands {
		comment := command.Comment
		if command.Name == "merge" {
			// TODO(alindeman): Enable when GitHub Enterprise supports this route.
			// For now, it's acceptable to fall back to the fact
			// that only fully compliant PRs can be merged in any case.
			//
			// permissionLevel, err := gh.GetUserPermissionLevel(pr.Owner, pr.Repository, comment.User.Login)
			// if err != nil {
			// 	log.Printf("error retrieving permission level for %s/%s, user %s: %v", pr.Owner, pr.Repository, comment.User.Login, err)
			// 	continue
			// } else if permissionLevel != github.PermissionLevelAdmin && permissionLevel != github.PermissionLevelWrite {
			// 	log.Printf("user %s does not have write access to %s/%s, ignoring merge command", comment.User.Login, pr.Owner, pr.Repository)
			// 	continue
			// }

			// TODO(alindeman): Check that the /merge command was issued after the last push
			if *pr.Mergeable {
				message := fmt.Sprintf("Automated merge, requested by @%s", comment.User.Login)
				err = gh.MergePullRequest(pr.Owner, pr.Repository, pr.Number, message)
				if err != nil {
					log.Printf("error merging pull request '%s': %v", pr, err)
					continue
				}
			} else {
				buf := new(bytes.Buffer)
				err := unmergablePrReplyComment.Execute(buf, comment)
				if err != nil {
					log.Printf("error rendering template: %v", err)
					continue
				}

				reply := &github.IssueReplyComment{
					Context: &mergeReplyCommentContext{
						InReplyToID: comment.ID,
					},
					Body: buf.String(),
				}

				err = gh.PostIssueComment(pr.Owner, pr.Repository, pr.Number, reply)
				if err != nil {
					log.Printf("error posting reply on pull request '%s': %v", pr, err)
				}
			}
		}
	}
	return nil
}
