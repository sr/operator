#!/usr/bin/env bash
set -uo pipefail
export PATH="$(pwd)/testing:$PATH"

TEST_log="${TEST_TMPDIR}/log"
touch "$TEST_log"

die() {
    printf "ERROR: %s\n\n" "$@"
    cat "$TEST_log"
    exit 1
}

operatorctl -help &>"$TEST_log"
grep -qs "Usage: operatorctl" "$TEST_log" ||
die "program help message did not include usage line"

operatorctl pinger boomtown &>"$TEST_log" &&
die "program did not exit non-zero for invalid method"

grep -qs "Service \"pinger\" has no method \"boomtown\"" "$TEST_log" ||
die "error message was incorrect"

operatorctl pinger --help &>"$TEST_log"
grep -qa "ping" "$TEST_log" ||
die "service help does not list ping method"
grep -qa "ping-pong" "$TEST_log" ||
die "service help does not list ping-pong method"
