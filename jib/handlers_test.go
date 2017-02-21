package jib_test

import (
	"fmt"
	"reflect"
	"regexp"

	"git.dev.pardot.com/Pardot/bread/jib/github"
)

type issueReplyCommentMatcher struct {
	Context interface{}

	BodyRegexps []*regexp.Regexp
}

func assertIssueReplyMatches(m *issueReplyCommentMatcher, comment *github.IssueReplyComment) error {
	if !reflect.DeepEqual(comment.Context, m.Context) {
		return fmt.Errorf("expected context to be %+v, but was %+v", m.Context, comment.Context)
	}

	for _, r := range m.BodyRegexps {
		if !r.MatchString(comment.Body) {
			return fmt.Errorf("expected body to match %+v, but did not: %v", r, comment.Body)
		}
	}

	return nil
}
