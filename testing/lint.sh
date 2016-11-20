#!/usr/bin/env bash
set -euo pipefail

out="$(
    cat testing/golint_gen_report.out |
    grep -v -E '^.*?\.pb.go' |
    grep -v "should have comment or be unexported" ||
    true
)"

if [ -n "$out" ]; then
    echo "$out"
    exit 1
fi

true
