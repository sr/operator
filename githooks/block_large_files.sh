#!/usr/bin/env bash
set -euo pipefail

readonly LARGE_FILE_SIZE="$((10*1024*1024))"
readonly NULL_SHA="0000000000000000000000000000000000000000"

large_files=()
while read -r oldref newref _; do
  if [ "$newref" = "$NULL_SHA" ]; then
    continue
  fi

  # Branch creation
  if [ "$oldref" = "$NULL_SHA" ]; then
    oldref="HEAD"
  fi

  report="$(git rev-list --objects "${oldref}..${newref}" | \
    git cat-file --batch-check='%(objectname) %(objecttype) %(objectsize) %(rest)')"

  while read -r _ type size name; do
    if [ "$type" != "blob" ]; then
      continue
    fi

    if [ "$size" -ge "$LARGE_FILE_SIZE" ]; then
      large_files+=("$name")
    fi
  done <<<"$report"
done

if [ "${#large_files[@]}" -gt 0 ]; then
  echo "--------------------------------------------------------------------------------"
  echo "Your push was blocked because it attempted to upload a file larger than"
  echo "${LARGE_FILE_SIZE} bytes"
  echo ""
  echo "Git is not a good store for large files. Please discuss with the @Pardot/ops"
  echo "team to find a more appropriate place to store large files."
  echo ""
  echo "NOTE: Deleting large files in a new commit will not resolve the issue. The"
  echo "GitHub documentation explains how to use bfg or git filter-branch to completely"
  echo "remove the file from history:"
  echo " - https://help.github.com/articles/removing-sensitive-data-from-a-repository/"
  echo ""
  echo "Files:"
  for file in "${large_files[@]}"; do
    echo " - ${file}"
  done
  echo "--------------------------------------------------------------------------------"
  exit 1
fi

exit 0
