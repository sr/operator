#!/usr/bin/env bash
set -euo pipefail

RUNFILES=${RUNFILES:-$0.runfiles}
GOLINT="$RUNFILES/com_github_golang_lint/golint/golint"

"$GOLINT" > "$1"
