package jib_test

import (
	"reflect"
	"testing"

	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb"
	"git.dev.pardot.com/Pardot/infrastructure/bread/jib"
)

func TestNotifyCommandHandler(t *testing.T) {
	cases := []struct {
		name             string
		pullRequestFiles []string
		watchlists       []*breadpb.RepositoryWatchlist
		expectedMatches  map[string][]string
	}{
		// Match full filepaths
		{
			name: "notify-handler/match-full-filepaths",
			pullRequestFiles: []string{
				"path/to/files/01.txt",
				"path/to/files/02.txt",
				"path/to/files/03.txt",
			},
			watchlists: []*breadpb.RepositoryWatchlist{
				{
					Name: "watchlist-one",
					Watchers: []string{
						"anthony-stark",
					},
					Files: []string{
						"path/to/files/01.txt",
					},
				},
				{
					Name: "watchlist-two",
					Watchers: []string{
						"bruce-banner",
					},
					Files: []string{
						"path/to/files/04.txt",
					},
				},
			},
			expectedMatches: map[string][]string{
				"anthony-stark": {
					"path/to/files/01.txt",
				},
			},
		},
		// Match directories
		{
			name: "notify-handler/match-directories",
			pullRequestFiles: []string{
				"path/to/files/01.txt",
				"path/to/files/02.txt",
				"path/to/files/03.txt",
				"another/path/to/files/04.txt",
			},
			watchlists: []*breadpb.RepositoryWatchlist{
				{
					Name: "watchlist-one",
					Watchers: []string{
						"anthony-stark",
					},
					Files: []string{
						"path/to/files/*",
					},
				},
				{
					Name: "watchlist-two",
					Watchers: []string{
						"bruce-banner",
					},
					Files: []string{
						"another/path/to/files/*",
						"another/path/to/files/01.txt",
						"another/path/to/files/05.txt",
					},
				},
			},
			expectedMatches: map[string][]string{
				"anthony-stark": {
					"path/to/files/01.txt",
					"path/to/files/02.txt",
					"path/to/files/03.txt",
				},
				"bruce-banner": {
					"another/path/to/files/04.txt",
				},
			},
		},
		// Match glob pattern with wildcards
		{
			name: "notify-handler/match-glob-pattern-with-wildcards",
			pullRequestFiles: []string{
				"path/to/files/01.txt",
				"path/to/files/02.txt",
				"path/to/files/03.txt",
				"another/path/to/files/04.txt",
				"another/path/to/files/05.exe",
			},
			watchlists: []*breadpb.RepositoryWatchlist{
				{
					Name: "watchlist-one",
					Watchers: []string{
						"anthony-stark",
					},
					Files: []string{
						"path/to/files/*.exe",
					},
				},
				{
					Name: "watchlist-two",
					Watchers: []string{
						"bruce-banner",
					},
					Files: []string{
						"path/to/files/?1.txt",
						"*.exe",
					},
				},
				{
					Name: "watchlist-three",
					Watchers: []string{
						"charles-xavier",
					},
					Files: []string{
						"path/to/files/??.txt",
						"another/path/to/files/*.exe",
					},
				},
			},
			expectedMatches: map[string][]string{
				"bruce-banner": {
					"another/path/to/files/05.exe",
					"path/to/files/01.txt",
				},
				"charles-xavier": {
					"another/path/to/files/05.exe",
					"path/to/files/01.txt",
					"path/to/files/02.txt",
					"path/to/files/03.txt",
				},
			},
		},
	}

	for _, tc := range cases {
		matches, err := jib.GetAllWatchlistsMatches(tc.pullRequestFiles, tc.watchlists)
		if err != nil {
			t.Errorf("[%v] Unexpected error while getting watchlist matches: %v\n", tc.name, err)
		}

		if !reflect.DeepEqual(matches, tc.expectedMatches) {
			t.Errorf("[%v] Failed to find all expected matches: expected=%v, actual=%v\n", tc.name, tc.expectedMatches, matches)
		}
	}
}
