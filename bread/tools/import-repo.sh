#!/usr/bin/env bash
set -euo pipefail

REPOHOME="$(cd "$(dirname "$0")"; pwd -P)/../.."

if [ "$#" -ne 2 ]; then
    echo "This script will import a repository from github into a subfolder, maintaining"
    echo "all git history and linking to the original commits"
    echo ""
    echo "USAGE: $0 <src repo url> <destination subdirectory>"
    exit 1
fi

function say {
    echo "--> $*"
}

repo_url="$1"
subdir="$2"

if [ -d "$subdir" ]; then
    say "$subdir already exists, aborting"
    exit 1
fi

wkdir="$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')"
function cleanup {
    rm -rf "$wkdir"
    git remote rm "$subdir-import" || true
}
trap cleanup EXIT

cd "$wkdir"
say "cloning in to temp dir"
git clone "$repo_url"
cd "$(basename "$repo_url")"
say "rewriting history in to target path"
git filter-branch --prune-empty --tree-filter "
if [ ! -e $subdir ]; then
    mkdir -p $subdir
    git ls-tree --name-only \$GIT_COMMIT | xargs -I files mv files $subdir
fi" --msg-filter "
sed -E 's%pull request #([0-9]+)%pull request '\"$repo_url\"'/pull/\1%' && \
echo \"\" && \
echo \"Original-Commit: \$GIT_COMMIT\" &&\
echo \"Original-Commit-URL: $repo_url/commit/\$GIT_COMMIT\"
"
cd "$REPOHOME"
say "importing result"
git remote rm "$subdir-import" || true
git remote add "$subdir-import" "$wkdir/$(basename "$repo_url")"
git fetch "$subdir-import"
git merge --allow-unrelated-histories -m "Import $repo_url" "$subdir-import/master"
say "cleaning up"

say "Forcing agressive GC of repo to clean up"
git gc --aggressive

say "DONE"
