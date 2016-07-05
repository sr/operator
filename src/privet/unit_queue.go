package privet

import "time"

type UnitQueue struct {
	queuesBySuite map[string][]*Unit
	size          int
}

func NewUnitQueue() *UnitQueue {
	return NewUnitQueueWithUnits([]*Unit{})
}

func NewUnitQueueWithUnits(units []*Unit) *UnitQueue {
	queue := &UnitQueue{
		queuesBySuite: make(map[string][]*Unit),
		size:          0,
	}

	for _, unit := range units {
		queue.Enqueue(unit)
	}

	return queue
}

func (q *UnitQueue) Enqueue(unit *Unit) {
	suiteQueue, ok := q.queuesBySuite[unit.Suite]
	if !ok {
		suiteQueue = []*Unit{}
		q.queuesBySuite[unit.Suite] = suiteQueue
	}

	q.queuesBySuite[unit.Suite] = append(suiteQueue, unit)
	q.size++
}

func (q *UnitQueue) Size() int {
	return q.size
}

func (q *UnitQueue) IsEmpty() bool {
	return q.size <= 0
}

// Dequeue returns a list of Units that will take approximately
// approximateDuration. Dequeue may return a list of units that exceeds
// approximateDuration, but if it does, it will be a list of one single Unit whose
// single duration is larger than approximateDuration. Otherwise, it will always
// keep the total duration under approximateDuration.
func (q *UnitQueue) Dequeue(approximateDuration time.Duration) []*Unit {
	if len(q.queuesBySuite) <= 0 {
		return []*Unit{}
	}

	// Grab any ol' suite. We just need to find the first suite that still has
	// units to run.
	var suite string
	for key := range q.queuesBySuite {
		suite = key
		break
	}

	totalApproximateDuration := 0 * time.Second
	queue := q.queuesBySuite[suite]
	units := []*Unit{}
	for len(queue) > 0 {
		unit := queue[0]
		var expectedRuntimeDuration time.Duration
		if unit.ExpectedRuntimeInSeconds > 0 {
			expectedRuntimeDuration = time.Duration(unit.ExpectedRuntimeInSeconds) * time.Second
		} else {
			expectedRuntimeDuration = 1 * time.Second
		}

		newTotalApproximateDuration := totalApproximateDuration + expectedRuntimeDuration
		if len(units) == 0 || newTotalApproximateDuration <= approximateDuration {
			units = append(units, unit)
			queue = queue[1:] // shift
			totalApproximateDuration = newTotalApproximateDuration
		} else {
			// Adding this unit would cause us to go over the approximateDuration,
			// violating the contract of this method
			break
		}
	}

	// If the suite queue has emptied out completely, remove it as a key;
	// otherwise, update the head pointer
	if len(queue) == 0 {
		delete(q.queuesBySuite, suite)
	} else {
		q.queuesBySuite[suite] = queue
	}

	q.size -= len(units)
	return units
}
