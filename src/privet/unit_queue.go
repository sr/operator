package privet

import "time"

type UnitQueue struct {
	units []*Unit
}

func NewUnitQueue() *UnitQueue {
	return NewUnitQueueWithUnits([]*Unit{})
}

func NewUnitQueueWithUnits(units []*Unit) *UnitQueue {
	return &UnitQueue{
		units: units,
	}
}

func (q *UnitQueue) Enqueue(unit *Unit) {
	q.units = append(q.units, unit)
}

func (q *UnitQueue) Size() int {
	return len(q.units)
}

func (q *UnitQueue) IsEmpty() bool {
	return len(q.units) <= 0
}

// Dequeue returns a list of Units that will take approximately
// approximateDuration. Dequeue may return a list of units that exceeds
// approximateDuration, but if it does, it will be a list of one single Unit whose
// single duration is larger than approximateDuration. Otherwise, it will always
// keep the total duration under approximateDuration.
func (q *UnitQueue) Dequeue(approximateDuration time.Duration) []*Unit {
	totalApproximateDuration := 0 * time.Second
	units := []*Unit{}
	for !q.IsEmpty() {
		unit := q.units[0]
		var expectedRuntimeDuration time.Duration
		if unit.ExpectedRuntimeInSeconds > 0 {
			expectedRuntimeDuration = time.Duration(unit.ExpectedRuntimeInSeconds) * time.Second
		} else {
			expectedRuntimeDuration = 1 * time.Second
		}

		newTotalApproximateDuration := totalApproximateDuration + expectedRuntimeDuration
		if len(units) == 0 || newTotalApproximateDuration <= approximateDuration {
			units = append(units, unit)
			q.units = q.units[1:] // shift
			totalApproximateDuration = newTotalApproximateDuration
		} else {
			// Adding this unit would cause us to go over the approximateDuration,
			// violating the contract of this method
			break
		}
	}

	return units
}
