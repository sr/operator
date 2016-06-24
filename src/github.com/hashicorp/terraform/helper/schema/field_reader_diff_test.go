package schema

import (
	"reflect"
	"testing"

	"github.com/hashicorp/terraform/terraform"
)

func TestDiffFieldReader_impl(t *testing.T) {
	var _ FieldReader = new(DiffFieldReader)
}

// https://github.com/hashicorp/terraform/issues/914
func TestDiffFieldReader_MapHandling(t *testing.T) {
	schema := map[string]*Schema{
		"tags": {
			Type: TypeMap,
		},
	}
	r := &DiffFieldReader{
		Schema: schema,
		Diff: &terraform.InstanceDiff{
			Attributes: map[string]*terraform.ResourceAttrDiff{
				"tags.%": {
					Old: "1",
					New: "2",
				},
				"tags.baz": {
					Old: "",
					New: "qux",
				},
			},
		},
		Source: &MapFieldReader{
			Schema: schema,
			Map: BasicMapReader(map[string]string{
				"tags.%":   "1",
				"tags.foo": "bar",
			}),
		},
	}

	result, err := r.ReadField([]string{"tags"})
	if err != nil {
		t.Fatalf("ReadField failed: %#v", err)
	}

	expected := map[string]interface{}{
		"foo": "bar",
		"baz": "qux",
	}

	if !reflect.DeepEqual(expected, result.Value) {
		t.Fatalf("bad: DiffHandling\n\nexpected: %#v\n\ngot: %#v\n\n", expected, result.Value)
	}
}

func TestDiffFieldReader_extra(t *testing.T) {
	schema := map[string]*Schema{
		"stringComputed": {Type: TypeString},

		"listMap": {
			Type: TypeList,
			Elem: &Schema{
				Type: TypeMap,
			},
		},

		"mapRemove": {Type: TypeMap},

		"setChange": {
			Type:     TypeSet,
			Optional: true,
			Elem: &Resource{
				Schema: map[string]*Schema{
					"index": {
						Type:     TypeInt,
						Required: true,
					},

					"value": {
						Type:     TypeString,
						Required: true,
					},
				},
			},
			Set: func(a interface{}) int {
				m := a.(map[string]interface{})
				return m["index"].(int)
			},
		},

		"setEmpty": {
			Type:     TypeSet,
			Optional: true,
			Elem: &Resource{
				Schema: map[string]*Schema{
					"index": {
						Type:     TypeInt,
						Required: true,
					},

					"value": {
						Type:     TypeString,
						Required: true,
					},
				},
			},
			Set: func(a interface{}) int {
				m := a.(map[string]interface{})
				return m["index"].(int)
			},
		},
	}

	r := &DiffFieldReader{
		Schema: schema,
		Diff: &terraform.InstanceDiff{
			Attributes: map[string]*terraform.ResourceAttrDiff{
				"stringComputed": {
					Old:         "foo",
					New:         "bar",
					NewComputed: true,
				},

				"listMap.0.bar": {
					NewRemoved: true,
				},

				"mapRemove.bar": {
					NewRemoved: true,
				},

				"setChange.10.value": {
					Old: "50",
					New: "80",
				},

				"setEmpty.#": {
					Old: "2",
					New: "0",
				},
			},
		},

		Source: &MapFieldReader{
			Schema: schema,
			Map: BasicMapReader(map[string]string{
				"listMap.#":     "2",
				"listMap.0.foo": "bar",
				"listMap.0.bar": "baz",
				"listMap.1.baz": "baz",

				"mapRemove.foo": "bar",
				"mapRemove.bar": "bar",

				"setChange.#":        "1",
				"setChange.10.index": "10",
				"setChange.10.value": "50",

				"setEmpty.#":        "2",
				"setEmpty.10.index": "10",
				"setEmpty.10.value": "50",
				"setEmpty.20.index": "20",
				"setEmpty.20.value": "50",
			}),
		},
	}

	cases := map[string]struct {
		Addr   []string
		Result FieldReadResult
		Err    bool
	}{
		"stringComputed": {
			[]string{"stringComputed"},
			FieldReadResult{
				Value:    "",
				Exists:   true,
				Computed: true,
			},
			false,
		},

		"listMapRemoval": {
			[]string{"listMap"},
			FieldReadResult{
				Value: []interface{}{
					map[string]interface{}{
						"foo": "bar",
					},
					map[string]interface{}{
						"baz": "baz",
					},
				},
				Exists: true,
			},
			false,
		},

		"mapRemove": {
			[]string{"mapRemove"},
			FieldReadResult{
				Value: map[string]interface{}{
					"foo": "bar",
				},
				Exists:   true,
				Computed: false,
			},
			false,
		},

		"setChange": {
			[]string{"setChange"},
			FieldReadResult{
				Value: []interface{}{
					map[string]interface{}{
						"index": 10,
						"value": "80",
					},
				},
				Exists: true,
			},
			false,
		},

		"setEmpty": {
			[]string{"setEmpty"},
			FieldReadResult{
				Value:  []interface{}{},
				Exists: true,
			},
			false,
		},
	}

	for name, tc := range cases {
		out, err := r.ReadField(tc.Addr)
		if err != nil != tc.Err {
			t.Fatalf("%s: err: %s", name, err)
		}
		if s, ok := out.Value.(*Set); ok {
			// If it is a set, convert to a list so its more easily checked.
			out.Value = s.List()
		}
		if !reflect.DeepEqual(tc.Result, out) {
			t.Fatalf("%s: bad: %#v", name, out)
		}
	}
}

func TestDiffFieldReader(t *testing.T) {
	testFieldReader(t, func(s map[string]*Schema) FieldReader {
		return &DiffFieldReader{
			Schema: s,
			Diff: &terraform.InstanceDiff{
				Attributes: map[string]*terraform.ResourceAttrDiff{
					"bool": {
						Old: "",
						New: "true",
					},

					"int": {
						Old: "",
						New: "42",
					},

					"float": {
						Old: "",
						New: "3.1415",
					},

					"string": {
						Old: "",
						New: "string",
					},

					"stringComputed": {
						Old:         "foo",
						New:         "bar",
						NewComputed: true,
					},

					"list.#": {
						Old: "0",
						New: "2",
					},

					"list.0": {
						Old: "",
						New: "foo",
					},

					"list.1": {
						Old: "",
						New: "bar",
					},

					"listInt.#": {
						Old: "0",
						New: "2",
					},

					"listInt.0": {
						Old: "",
						New: "21",
					},

					"listInt.1": {
						Old: "",
						New: "42",
					},

					"map.foo": {
						Old: "",
						New: "bar",
					},

					"map.bar": {
						Old: "",
						New: "baz",
					},

					"set.#": {
						Old: "0",
						New: "2",
					},

					"set.10": {
						Old: "",
						New: "10",
					},

					"set.50": {
						Old: "",
						New: "50",
					},

					"setDeep.#": {
						Old: "0",
						New: "2",
					},

					"setDeep.10.index": {
						Old: "",
						New: "10",
					},

					"setDeep.10.value": {
						Old: "",
						New: "foo",
					},

					"setDeep.50.index": {
						Old: "",
						New: "50",
					},

					"setDeep.50.value": {
						Old: "",
						New: "bar",
					},
				},
			},

			Source: &MapFieldReader{
				Schema: s,
				Map: BasicMapReader(map[string]string{
					"listMap.#":     "2",
					"listMap.0.foo": "bar",
					"listMap.0.bar": "baz",
					"listMap.1.baz": "baz",
				}),
			},
		}
	})
}
