package jib

import (
	"fmt"
	"jib/github"
	"log"
)

type PullRequestHandler func(gh github.Client, pr *github.PullRequest) error

func InfoHandler(gh github.Client, pr *github.PullRequest) error {
	log.Printf("processing %s/%s#%d titled '%s'\n", pr.Owner, pr.Repository, pr.Number, pr.Title)
	return nil
}

func MergeCommandHandler(gh github.Client, pr *github.PullRequest) error {
	if pr.Mergeable == nil || !*pr.Mergeable {
		log.Printf("pull request '%s' is not mergeable, skipping", pr)
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

			message := fmt.Sprintf("Automated merge, requested by @%s", comment.User.Login)
			err = gh.MergePullRequest(pr.Owner, pr.Repository, pr.Number, message)
			if err != nil {
				log.Printf("error merging pull request '%s': %v", pr, err)
				continue
			}
		}
	}
	return nil
}
