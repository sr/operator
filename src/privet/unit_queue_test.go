package privet

import (
	"testing"
	"time"
)

func TestUnitQueueAssumesExpectedRuntimeAsOneSecondIfAbsent(t *testing.T) {
	unitQueue := NewUnitQueueWithUnits([]*Unit{
		{Data: "unit1"},
		{Data: "unit2"},
		{Data: "unit3"},
	})

	units := unitQueue.Dequeue(1 * time.Second)
	if len(units) != 1 {
		t.Fatalf("expected to dequeue 1 unit, but got %v", units)
	}

	units = unitQueue.Dequeue(2 * time.Second)
	if len(units) != 2 {
		t.Fatalf("expected to dequeue 2 units, but got %v", units)
	}

	if !unitQueue.IsEmpty() {
		t.Fatalf("expected queue to be empty, but was not")
	}
}

func TestUnitQueueAttemptsToPackageTestsIntoEqualSizedChunksWithoutGoingOver(t *testing.T) {
	unitQueue := NewUnitQueueWithUnits([]*Unit{
		{Data: "unit1", ExpectedRuntimeInSeconds: 1},
		{Data: "unit2", ExpectedRuntimeInSeconds: 2},
		{Data: "unit3", ExpectedRuntimeInSeconds: 5},
	})

	units := unitQueue.Dequeue(5 * time.Second)
	if len(units) != 2 {
		t.Fatalf("expected to dequeue 2 units, but got %v", units)
	}

	units = unitQueue.Dequeue(5 * time.Second)
	if len(units) != 1 {
		t.Fatalf("expected to dequeue 1 units, but got %v", units)
	}

	if !unitQueue.IsEmpty() {
		t.Fatalf("expected queue to be empty, but was not")
	}
}
