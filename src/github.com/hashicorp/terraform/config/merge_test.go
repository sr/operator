package config

import (
	"reflect"
	"testing"
)

func TestMerge(t *testing.T) {
	cases := []struct {
		c1, c2, result *Config
		err            bool
	}{
		// Normal good case.
		{
			&Config{
				Atlas: &AtlasConfig{
					Name: "foo",
				},
				Modules: []*Module{
					{Name: "foo"},
				},
				Outputs: []*Output{
					{Name: "foo"},
				},
				ProviderConfigs: []*ProviderConfig{
					{Name: "foo"},
				},
				Resources: []*Resource{
					{Name: "foo"},
				},
				Variables: []*Variable{
					{Name: "foo"},
				},

				unknownKeys: []string{"foo"},
			},

			&Config{
				Atlas: &AtlasConfig{
					Name: "bar",
				},
				Modules: []*Module{
					{Name: "bar"},
				},
				Outputs: []*Output{
					{Name: "bar"},
				},
				ProviderConfigs: []*ProviderConfig{
					{Name: "bar"},
				},
				Resources: []*Resource{
					{Name: "bar"},
				},
				Variables: []*Variable{
					{Name: "bar"},
				},

				unknownKeys: []string{"bar"},
			},

			&Config{
				Atlas: &AtlasConfig{
					Name: "bar",
				},
				Modules: []*Module{
					{Name: "foo"},
					{Name: "bar"},
				},
				Outputs: []*Output{
					{Name: "foo"},
					{Name: "bar"},
				},
				ProviderConfigs: []*ProviderConfig{
					{Name: "foo"},
					{Name: "bar"},
				},
				Resources: []*Resource{
					{Name: "foo"},
					{Name: "bar"},
				},
				Variables: []*Variable{
					{Name: "foo"},
					{Name: "bar"},
				},

				unknownKeys: []string{"foo", "bar"},
			},

			false,
		},

		// Test that when merging duplicates, it merges into the
		// first, but keeps the duplicates so that errors still
		// happen.
		{
			&Config{
				Outputs: []*Output{
					{Name: "foo"},
				},
				ProviderConfigs: []*ProviderConfig{
					{Name: "foo"},
				},
				Resources: []*Resource{
					{Name: "foo"},
				},
				Variables: []*Variable{
					{Name: "foo", Default: "foo"},
					{Name: "foo"},
				},

				unknownKeys: []string{"foo"},
			},

			&Config{
				Outputs: []*Output{
					{Name: "bar"},
				},
				ProviderConfigs: []*ProviderConfig{
					{Name: "bar"},
				},
				Resources: []*Resource{
					{Name: "bar"},
				},
				Variables: []*Variable{
					{Name: "foo", Default: "bar"},
					{Name: "bar"},
				},

				unknownKeys: []string{"bar"},
			},

			&Config{
				Outputs: []*Output{
					{Name: "foo"},
					{Name: "bar"},
				},
				ProviderConfigs: []*ProviderConfig{
					{Name: "foo"},
					{Name: "bar"},
				},
				Resources: []*Resource{
					{Name: "foo"},
					{Name: "bar"},
				},
				Variables: []*Variable{
					{Name: "foo", Default: "bar"},
					{Name: "foo"},
					{Name: "bar"},
				},

				unknownKeys: []string{"foo", "bar"},
			},

			false,
		},
	}

	for i, tc := range cases {
		actual, err := Merge(tc.c1, tc.c2)
		if err != nil != tc.err {
			t.Fatalf("%d: error fail", i)
		}

		if !reflect.DeepEqual(actual, tc.result) {
			t.Fatalf("%d: bad:\n\n%#v", i, actual)
		}
	}
}
