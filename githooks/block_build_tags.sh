#!/usr/bin/env bash
set -euo pipefail

readonly NULL_SHA="0000000000000000000000000000000000000000"

while read -r _ newref refname; do
  if [ "$newref" = "$NULL_SHA" ]; then
    continue
  fi

  if echo -n "$refname" | grep -q "^refs/tags/build"; then
    echo "--------------------------------------------------------------------------------"
    echo "Your push was blocked because it attempted to create a tag named '${refname}'"
    echo ""
    echo "Please only push branches, not build tags to keep our repository lean"
    echo "--------------------------------------------------------------------------------"
    exit 1
  fi
done

exit 0
