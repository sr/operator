#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

: "${TEST_TMPDIR:="$(mktemp -d)"}"

# Install protoc-gen-operatord and protoc-gen-operatorctl
go install -v github.com/sr/operator/cmd/...

# Generater operatorctl code from testing.proto using protoc-gen-operatorctl
protoc \
    -I"$(brew --prefix protobuf)/include" \
    -Itesting \
    -I. \
    --operatorctl_out="import_path=github.com/sr/operator/testing:${TEST_TMPDIR}" \
    testing/*.proto

# Compile generated code into operatorctl and place it on the PATH
mkdir "${TEST_TMPDIR}/bin"
go build -o "${TEST_TMPDIR}/bin/operatorctl" "${TEST_TMPDIR}/main-gen.go"
PATH="${TEST_TMPDIR}/bin:$PATH"
export PATH

TEST_log="${TEST_TMPDIR}/log"
touch "$TEST_log"

fail() {
    printf "FAILURE: %s\n\n" "$@"
    cat "$TEST_log"
    exit 1
}

operatorctl -help &>"$TEST_log"
if ! grep -qs "Usage: operatorctl" "$TEST_log"; then
	fail "program help message did not include usage line"
fi

if operatorctl pinger boomtown &>"$TEST_log"; then
	fail "program did not exit non-zero for invalid method"
fi

if ! grep -qs "Service \"pinger\" has no method \"boomtown\"" "$TEST_log"; then
	fail "error message was incorrect"
fi

operatorctl pinger --help &>"$TEST_log"

if ! grep -qa "ping" "$TEST_log"; then
    fail "service help does not list ping method"
fi

if ! grep -qa "ping-pong" "$TEST_log"; then
    fail "service help does not list ping-pong method"
fi
