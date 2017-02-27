#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

: "${TEST_TMPDIR:="$(mktemp -d)"}"

# Install protoc-gen-operatord and protoc-gen-operatorctl
go install -v github.com/sr/operator/cmd/...

# Generater operatorctl (client) and operatord (server) code from protobuf files
mkdir "${TEST_TMPDIR}/operatorctl" "${TEST_TMPDIR}/operatord"
protoc \
    -I"$(brew --prefix protobuf)/include" \
    -Itesting \
    -I. \
    --operatorctl_out="import_path=github.com/sr/operator/testing:${TEST_TMPDIR}/operatorctl" \
    --operatord_out="import_path=github.com/sr/operator/testing:${TEST_TMPDIR}/operatord" \
    testing/*.proto

# Compile generated client code into operatorctl and place it on the PATH
mkdir "${TEST_TMPDIR}/bin"
go build -o "${TEST_TMPDIR}/bin/operatorctl" "${TEST_TMPDIR}/operatorctl/main-gen.go"
PATH="${TEST_TMPDIR}/bin:$PATH"
export PATH

# Compile generated server code and discard it; this test only cares about
# whether the code compiles at this time
cat <<EOS > "${TEST_TMPDIR}/operatord/main.go"
package main
func main() {}
EOS
go build -o "${TEST_TMPDIR}/bin/operatord" "${TEST_TMPDIR}/operatord/main.go"
rm -f "${TEST_TMPDIR}/bin/operatord"

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
if grep -qa "private-service" "$TEST_log"; then
    fail "program help includes help for private service"
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
