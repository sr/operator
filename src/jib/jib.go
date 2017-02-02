package jib

import "jib/github"

const (
	complianceStatusContext = "compliance"
)

func findComplianceStatus(statuses []*github.CommitStatus) *github.CommitStatus {
	for _, status := range statuses {
		if status.Context == complianceStatusContext {
			return status
		}
	}

	return nil
}
