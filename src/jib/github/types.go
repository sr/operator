package github

import "fmt"

type PullRequest struct {
	Owner      string
	Repository string
	Number     int

	State string
	Title string

	// Mergeable is either true (mergeable), false (not mergeable), or null (not computed yet)
	Mergeable *bool
}

func (p *PullRequest) String() string {
	return fmt.Sprintf("%s/%s#%d \"%s\"", p.Owner, p.Repository, p.Number, p.Title)

}

type IssueComment struct {
	ID   int
	User *User
	Body string
}

type User struct {
	Login string
}

type PermissionLevel string

var (
	PermissionLevelAdmin PermissionLevel = "admin"
	PermissionLevelWrite PermissionLevel = "write"
)

func Bool(b bool) *bool {
	return &b
}
