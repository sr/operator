# privet

Privet is a test parallelization framework.

## Invocation

### Job Master

One job master should be run in a CI job:

```
privet -bind 0.0.0.0:4222
```

The master will exit with a `0` if all job runners complete succesfully. It will return with the first non-zero exit code it receives if any fail.

### Job Runner

As many job runners as you'd like can be run in other CI jobs:

```
privet -connect 192.168.101.1:4222
```

How the job runners find their master is left up to the reader. Using the API of the CI system is probably preferred, if possible.

It is possible to request that multiple units be run at one time. This might help the efficiency in cases where there are many small unit test files:

```
privet -connect 192.168.101.1:4222 -batch-units 10
```

## Scripts

To use Privet, your project must contain several executable scripts that help Privet know how to farm out the test suite to its workers.

By default, these scripts reside in `./test/privet`, but that directory can be customized when Privet is invoked.


### Environment Variables

Privet will set environment variables that can be used by the scripts:

* `PRIVET_RUNNER_ID`: Unique identifier for the job runner (if applicable)

### units

The `units` script is responsible for splitting the test suite into units that can be farmed out to workers. `units` must print one 'unit' per line, separated by `\n`. Each unit will be passed to the `run-units` script on job workers (described later).

In the simple case, `units` could return each test file, if that is the unit of granularity you want. It could also return something more complicated, like a line of JSON, if `run-units` would later know how to parse that.

Example:

```
$ ./units
test/FooTest.php
test/BarTest.php
```

### runner-hook-startup (optional)

The `runner-hook-startup` script is executed before a runner starts accepting test units. It should perform any setup tasks that are required for the test suite to run.

For example, `runner-hook-startup` might start a set of Docker containers that will be used to execute the tests.

### runner-run-units

The `run-units` script is used to execute a unit of test work on a job runner. It will be passed one or more units (generated from `units`) as arguments.

`run-units` should perform any per-unit initialization and cleanup steps before and after running the unit, respectively. It should return non-zero to indicate a test failure or error.

### runner-additional-results (optional)

Privet will automatically send stdout and stderr from `run-units` back to the job master. However, if additional output (e.g., a junit file) is also necessary, `runner-additional-results` can send back arbitrary files after the unit has been completed.

`runner-additional-results` will be invoked (if present) after each invocation of `run-units`.

### runner-hook-cleanup (optional)

The `runner-cleanup` script is executed after the job runner no longer has any work to do. It should clean up any global resources.

For example, `runner-cleanup` might stop the set of Docker containers it started earlier.

### receive-results

The `receive-results` script is executed on the job master after results are received from a runner. Whatever is output from `receive-results` will be output on the job master, and appear in the CI test results.

When invoked, several environment variables will be set:

* `PRIVET_RUNNER_ID`: The unique identifier of the runner that executed the unit
* `PRIVET_UNITS`: The units that were executed (separated by `\n`)
* `PRIVET_UNIT_RESULT_FILE`: A file containing output (stdout and stderr) from the unit run
* `PRIVET_UNIT_RESULT_CODE`: The exit code from the unit run
* `PRIVET_ADDITIONAL_RESULT_FILE`: A file containing output from `runner-additional-results` (if present)
* `PRIVET_ADDITIONAL_RESULT_CODE`: The exit code from `runner-additional-results` (if present)

Privet itself does not output any test results. It is expected that `receive-results` will do this. Common tasks in `receive-results` include:

* `cat "$PRIVET_UNIT_RESULT_FILE"`: Dump the contents of the result output file
* `mv "$PRIVET_ADDITIONAL_RESULT_FILE" "..."`: Move the result file to a location that will be later picked up by the CI system


## Future Work

* Resiliency to a test runner failing (hand out those units to another runner after a timeout)
