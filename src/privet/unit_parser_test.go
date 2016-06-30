package privet

import (
	"strings"
	"testing"
)

func TestUnitParserHappyPath(t *testing.T) {
	unitsAsJSON := []string{
		`{"data": "unit1", "expected_runtime_in_seconds": 4.24}`,
		`{"data": "unit2", "expected_runtime_in_seconds": 10.9}`,
	}
	reader := strings.NewReader(strings.Join(unitsAsJSON, "\n"))

	parser := NewUnitParser(reader)
	unit, err := parser.Next()
	if err != nil {
		t.Fatal(err)
	}
	if unit.Data != "unit1" {
		t.Errorf("expected %v, but got %v", "unit1", unit.Data)
	}
	if unit.ExpectedRuntimeInSeconds != 4.24 {
		t.Errorf("expected %v, but got %v", 4.24, unit.ExpectedRuntimeInSeconds)
	}

	unit, err = parser.Next()
	if err != nil {
		t.Fatal(err)
	}
	if unit.Data != "unit2" {
		t.Errorf("expected %v, but got %v", "unit2", unit.Data)
	}
	if unit.ExpectedRuntimeInSeconds != 10.9 {
		t.Errorf("expected %v, but got %v", 10.9, unit.ExpectedRuntimeInSeconds)
	}

	unit, err = parser.Next()
	if err != nil {
		t.Fatal(err)
	}
	if unit != nil {
		t.Errorf("expected unit to be nil when there are no more units, but got %v", unit)
	}
}
