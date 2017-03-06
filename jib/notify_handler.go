package jib

import (
	"bytes"
	"fmt"
	"html/template"
	"regexp"
	"sort"
	"strings"

	"git.dev.pardot.com/Pardot/bread/jib/github"
	"git.dev.pardot.com/Pardot/bread/pb"
	"github.com/golang/protobuf/jsonpb"
)

const (
	RepositoryConfigFilepath = "REPOSITORY.json"
	MasterRef                = "master"
)

var (
	notificationMessage = template.Must(template.New("").Parse(strings.TrimSpace(`
### Code Change Notification [:information_source:](https://salesforce.quip.com/0HazA054w8uP)
{{range $watcher, $files := .Matches}}<details><summary>@{{$watcher}}</summary><ul>{{range $files}}<li>{{.}}</li>{{end}}</ul></details>{{end}}`)))
)

type NotifyMessageContext struct {
	Matches map[string][]string
}

type NotifyReplyCommentContext struct {
	PullRequestID int
}

func (s *Server) Notify(pr *github.PullRequest) error {
	filenames, err := s.gh.GetPullRequestFiles(pr.Org, pr.Repository, pr.Number)
	if err != nil {
		return err
	}

	watchlists, err := getRepoWatchlists(s.gh, pr)
	if err != nil {
		return err
	}

	matches, err := GetAllWatchlistsMatches(filenames, watchlists)
	if err != nil {
		return err
	}

	return postNotificationComment(s.gh, pr, matches)
}

func getRepoWatchlists(gh github.Client, pr *github.PullRequest) ([]*breadpb.RepositoryWatchlist, error) {
	rc, err := getRepoWatchlistFile(gh, pr)
	if err != nil {
		return nil, err
	}

	return rc.GetWatchlists(), nil
}

func GetAllWatchlistsMatches(filenames []string, watchlists []*breadpb.RepositoryWatchlist) (map[string][]string, error) {
	compiledWatchlists, err := compileWatchlists(watchlists)
	if err != nil {
		return nil, err
	}

	allMatches := make(map[string][]string)
	for _, watchlist := range watchlists {
		watchlistMatches := getWatchlistMatches(watchlist, filenames, compiledWatchlists)
		if len(watchlistMatches) > 0 {
			for _, watcher := range watchlist.GetWatchers() {
				allMatches[watcher] = watchlistMatches
			}
		}
	}
	return allMatches, nil
}

func postNotificationComment(gh github.Client, pr *github.PullRequest, matches map[string][]string) error {
	if len(matches) == 0 {
		return nil
	}

	context := &NotifyMessageContext{
		Matches: matches,
	}

	body, err := renderTemplate(notificationMessage, context)
	if err != nil {
		return err
	}

	comment := &github.IssueReplyComment{
		Context: &NotifyReplyCommentContext{
			PullRequestID: pr.Number,
		},
		Body: body,
	}

	return gh.PostIssueComment(pr.Org, pr.Repository, pr.Number, comment)
}

func getRepoWatchlistFile(gh github.Client, pr *github.PullRequest) (*breadpb.RepositoryConfig, error) {
	file, err := gh.GetRepositoryFile(pr.Org, pr.Repository, RepositoryConfigFilepath, MasterRef)
	if err != nil {
		return nil, err
	}

	r := bytes.NewReader(file.Content)
	config := new(breadpb.RepositoryConfig)
	err = jsonpb.Unmarshal(r, config)
	if err != nil {
		return nil, err
	}
	return config, nil
}

func compileWatchlists(watchlists []*breadpb.RepositoryWatchlist) (map[string]*regexp.Regexp, error) {
	results := make(map[string]*regexp.Regexp)
	for _, watchlist := range watchlists {
		filenames := watchlist.GetFiles()
		for _, filename := range filenames {
			if _, ok := results[filename]; !ok {
				regex := glob2regex(filename)
				compiledRegex, err := regexp.Compile(regex)
				if err != nil {
					return nil, err
				}
				results[filename] = compiledRegex
			}
		}
	}
	return results, nil
}

func getWatchlistMatches(watchlist *breadpb.RepositoryWatchlist,
	filenames []string,
	compiledWatchlists map[string]*regexp.Regexp) []string {
	matches := make(map[string]struct{})
	watchlistFiles := watchlist.GetFiles()
	for _, watchlistFile := range watchlistFiles {
		for _, filename := range filenames {
			if compiledWatchlists[watchlistFile].MatchString(filename) {
				matches[filename] = struct{}{}
			}
		}
	}

	i := 0
	keys := make([]string, len(matches))
	for k := range matches {
		keys[i] = k
		i++
	}
	sort.Strings(keys)
	return keys
}

func glob2regex(g string) string {
	g = strings.Replace(g, ".", "\\.", -1)
	g = strings.Replace(g, "?", ".", -1)
	g = strings.Replace(g, "*", ".*", -1)
	return fmt.Sprintf("^%v$", g)
}
