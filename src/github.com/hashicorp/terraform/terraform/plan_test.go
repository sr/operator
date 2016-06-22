package terraform

import (
	"bytes"
	"strings"

	"testing"
)

func TestReadWritePlan(t *testing.T) {
	plan := &Plan{
		Module: testModule(t, "new-good"),
		Diff: &Diff{
			Modules: []*ModuleDiff{
				{
					Path: rootModulePath,
					Resources: map[string]*InstanceDiff{
						"nodeA": {
							Attributes: map[string]*ResourceAttrDiff{
								"foo": {
									Old: "foo",
									New: "bar",
								},
								"bar": {
									Old:         "foo",
									NewComputed: true,
								},
								"longfoo": {
									Old:         "foo",
									New:         "bar",
									RequiresNew: true,
								},
							},
						},
					},
				},
			},
		},
		State: &State{
			Modules: []*ModuleState{
				{
					Path: rootModulePath,
					Resources: map[string]*ResourceState{
						"foo": {
							Primary: &InstanceState{
								ID: "bar",
							},
						},
					},
				},
			},
		},
		Vars: map[string]string{
			"foo": "bar",
		},
	}

	buf := new(bytes.Buffer)
	if err := WritePlan(plan, buf); err != nil {
		t.Fatalf("err: %s", err)
	}

	actual, err := ReadPlan(buf)
	if err != nil {
		t.Fatalf("err: %s", err)
	}

	actualStr := strings.TrimSpace(actual.String())
	expectedStr := strings.TrimSpace(plan.String())
	if actualStr != expectedStr {
		t.Fatalf("bad:\n\n%s\n\nexpected:\n\n%s", actualStr, expectedStr)
	}
}
