package jib

import (
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
	unmergablePrReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.User.Login}} I can't merge this PR right now because the pull request is not in a mergeable state.

Please fix the issue and re-issue the /merge command and I'll get right to it.
`)))

	complianceStatusFailedPrReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.User.Login}} I can't merge this PR right now because the compliance status check failed.

Please fix the issue and re-issue the /merge command and I'll get right to it.
`)))

	prUpdatedAfterMergeCommandReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.User.Login}} I didn't merge this PR because it was updated after the /merge command was issued.

If you still want to merge, re-issue the /merge command and I'll get right to it.
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

	// Only react to the latest authorized merge command, if there is one.
	// Anything else would be very confusing to the user, as we might post
	// multiple comments.
	commands := ExtractCommands(comments, []string{gh.Username()})
	var latestMergeCommand *Command
	// Iterate from latest comment to earliest
	for i := len(commands) - 1; i >= 0; i-- {
		command := commands[i]
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

			latestMergeCommand = command
			break
		}
	}

	if latestMergeCommand == nil {
		// Nothing to do
		return nil
	}

	comment := latestMergeCommand.Comment
	if *pr.Mergeable {
		// If the PR was updated after the /merge
		// command was created, we must get the user to
		// verify their intent again.
		if pr.UpdatedAt.After(comment.CreatedAt) {
			body, err := renderTemplate(prUpdatedAfterMergeCommandReply, comment)
			if err != nil {
				return err
			}

			reply := &github.IssueReplyComment{
				Context: &mergeReplyCommentContext{
					InReplyToID: comment.ID,
				},
				Body: body,
			}

			err = gh.PostIssueComment(pr.Owner, pr.Repository, pr.Number, reply)
			if err != nil {
				return err
			}
		} else {
			statuses, err := gh.GetCommitStatuses(pr.Owner, pr.Repository, pr.HeadSHA)
			if err != nil {
				return err
			}

			complianceStatus := findComplianceStatus(statuses)
			if complianceStatus == nil || complianceStatus.State == github.CommitStatusPending {
				// Compliance check is unreported or pending;
				// nothing to do until it has a firm result
				return nil
			}

			if complianceStatus.State == github.CommitStatusSuccess {
				message := fmt.Sprintf("Automated merge, requested by @%s", comment.User.Login)
				err = gh.MergePullRequest(pr.Owner, pr.Repository, pr.Number, message)
				if err != nil {
					return err
				}
			} else if complianceStatus.State == github.CommitStatusFailure {
				body, err := renderTemplate(complianceStatusFailedPrReply, comment)
				if err != nil {
					return err
				}

				reply := &github.IssueReplyComment{
					Context: &mergeReplyCommentContext{
						InReplyToID: comment.ID,
					},
					Body: body,
				}

				err = gh.PostIssueComment(pr.Owner, pr.Repository, pr.Number, reply)
				if err != nil {
					return err
				}
			}
		}
	} else {
		body, err := renderTemplate(unmergablePrReply, comment)
		if err != nil {
			return err
		}

		reply := &github.IssueReplyComment{
			Context: &mergeReplyCommentContext{
				InReplyToID: comment.ID,
			},
			Body: body,
		}

		err = gh.PostIssueComment(pr.Owner, pr.Repository, pr.Number, reply)
		if err != nil {
			return err
		}
	}

	return nil
}
