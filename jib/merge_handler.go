package jib

import (
	"html/template"
	"log"
	"strings"

	"git.dev.pardot.com/Pardot/bread/jib/github"
)

type MergeReplyCommentContext struct {
	InReplyToID int
}

type mergeCommandContext struct {
	Command     *Command
	PullRequest *github.PullRequest
}

var (
	mergeCommandCommitMessage = template.Must(template.New("").Parse(strings.TrimSpace(`
Merge-requested-by: @{{.Command.Comment.User.Login}}
`)))

	unmergablePrReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.Command.Comment.User.Login}} I can't merge this PR right now because the pull request is not in a mergeable state.

Please fix the issue and re-issue the {{.Command}} command and I'll get right to it.
`)))

	complianceStatusFailedPrReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.Command.Comment.User.Login}} I can't merge this PR right now because the compliance status check failed.

Please fix the issue and re-issue the {{.Command}} command and I'll get right to it.
`)))

	prCommitAfterMergeCommandReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.Command.Comment.User.Login}} I didn't merge this PR because there was a commit created since the /merge command was issued.

If you still want to merge, re-issue the {{.Command}} command and I'll get right to it.
`)))

	notAuthorizedToEmergencyMergeReply = template.Must(template.New("").Parse(strings.TrimSpace(`
@{{.Command.Comment.User.Login}} I didn't perform an emergency merge for this PR because you are not a member of one of the teams allowed to authorize emergency merges.

If this pull request requires an emergency merge, please find someone on the app-on-call, engineering-managers, customer-centric-engineering, or site-reliability-engineers teams to issue the {{.Command}} command and I'll get right to it.
`)))
)

func (s *Server) Merge(pr *github.PullRequest) error {
	if pr.Mergeable == nil {
		log.Printf("pull request '%s' has undetermined mergeability, skipping for now", pr)
		return nil
	}

	comments, err := s.gh.GetIssueComments(pr.Org, pr.Repository, pr.Number)
	if err != nil {
		return err
	}

	// Only react to the latest authorized merge command, if there is one.
	// Anything else would be very confusing to the user, as we might post
	// multiple comments.
	commands := ExtractCommands(comments, []string{s.gh.Username()})
	var latestMergeCommand *Command
	// Iterate from latest comment to earliest
	for i := len(commands) - 1; i >= 0; i-- {
		command := commands[i]
		if command.Name == "merge" || command.Name == "emergency-merge" {
			// TODO(alindeman): Enable when GitHub Enterprise supports this route.
			// For now, it's acceptable to fall back to the fact
			// that only fully compliant PRs can be merged in any case.
			//
			// permissionLevel, err := s.gh.GetUserPermissionLevel(pr.Org, pr.Repository, comment.User.Login)
			// if err != nil {
			// 	log.Printf("error retrieving permission level for %s/%s, user %s: %v", pr.Org, pr.Repository, comment.User.Login, err)
			// 	continue
			// } else if permissionLevel != github.PermissionLevelAdmin && permissionLevel != github.PermissionLevelWrite {
			// 	log.Printf("user %s does not have write access to %s/%s, ignoring merge command", comment.User.Login, pr.Org, pr.Repository)
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

	context := &mergeCommandContext{
		Command:     latestMergeCommand,
		PullRequest: pr,
	}

	if *pr.Mergeable {
		commitsSinceCommand, err := s.gh.GetCommitsSince(pr.Org, pr.Repository, pr.HeadSHA, context.Command.Comment.CreatedAt)
		if err != nil {
			return err
		}
		commitsSinceCommand = s.filterCIAutomatedMerges(commitsSinceCommand)

		// If the PR was updated after the merge command was created, we
		// must get the user to verify their intent again.
		if len(commitsSinceCommand) > 0 {
			body, err := renderTemplate(prCommitAfterMergeCommandReply, context)
			if err != nil {
				return err
			}

			reply := &github.IssueReplyComment{
				Context: &MergeReplyCommentContext{
					InReplyToID: context.Command.Comment.ID,
				},
				Body: body,
			}

			err = s.gh.PostIssueComment(pr.Org, pr.Repository, pr.Number, reply)
			if err != nil {
				return err
			}
		} else {
			if context.Command.Name == "emergency-merge" {
				return s.performEmergencyMerge(context)
			}
			return s.performStandardMerge(context)
		}
	} else {
		body, err := renderTemplate(unmergablePrReply, context)
		if err != nil {
			return err
		}

		reply := &github.IssueReplyComment{
			Context: &MergeReplyCommentContext{
				InReplyToID: context.Command.Comment.ID,
			},
			Body: body,
		}

		err = s.gh.PostIssueComment(pr.Org, pr.Repository, pr.Number, reply)
		if err != nil {
			return err
		}
	}

	return nil
}

func (s *Server) performStandardMerge(context *mergeCommandContext) error {
	pr := context.PullRequest

	statuses, err := s.gh.GetCommitStatuses(pr.Org, pr.Repository, pr.HeadSHA)
	if err != nil {
		return err
	}

	complianceStatus := s.findComplianceStatus(statuses)
	if complianceStatus == nil || complianceStatus.State == github.CommitStatusPending {
		// Compliance check is unreported or pending;
		// nothing to do until it has a firm result
		return nil
	}

	if complianceStatus.State == github.CommitStatusSuccess {
		message, err := renderTemplate(mergeCommandCommitMessage, context)
		if err != nil {
			return err
		}

		err = s.gh.MergePullRequest(pr.Org, pr.Repository, pr.Number, message)
		if err != nil {
			return err
		}

		err = s.gh.EnsureBranchDeleted(pr.Org, pr.Repository, pr.HeadRef)
		if err != nil {
			return err
		}
	} else if complianceStatus.State == github.CommitStatusFailure {
		body, err := renderTemplate(complianceStatusFailedPrReply, context)
		if err != nil {
			return err
		}

		reply := &github.IssueReplyComment{
			Context: &MergeReplyCommentContext{
				InReplyToID: context.Command.Comment.ID,
			},
			Body: body,
		}

		err = s.gh.PostIssueComment(pr.Org, pr.Repository, pr.Number, reply)
		if err != nil {
			return err
		}
	}

	return nil
}

func (s *Server) performEmergencyMerge(context *mergeCommandContext) error {
	pr := context.PullRequest

	isMember, err := s.gh.IsMemberOfAnyTeam(pr.Org, context.Command.Comment.User.Login, s.config.EmergencyMergeAuthorizedTeams)
	if err != nil {
		return err
	}

	if isMember {
		// User is allowed to authorize an emergency merge
		message, err := renderTemplate(mergeCommandCommitMessage, context)
		if err != nil {
			return err
		}

		err = s.gh.MergePullRequest(pr.Org, pr.Repository, pr.Number, message)
		if err != nil {
			return err
		}

		err = s.gh.EnsureBranchDeleted(pr.Org, pr.Repository, pr.HeadRef)
		if err != nil {
			return err
		}

		return nil
	}

	// User is not authorized
	body, err := renderTemplate(notAuthorizedToEmergencyMergeReply, context)
	if err != nil {
		return nil
	}

	reply := &github.IssueReplyComment{
		Context: &MergeReplyCommentContext{
			InReplyToID: context.Command.Comment.ID,
		},
		Body: body,
	}

	err = s.gh.PostIssueComment(pr.Org, pr.Repository, pr.Number, reply)
	if err != nil {
		return err
	}

	return nil
}
