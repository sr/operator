#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ge 1 ] && [ "$1" = "/usr/sbin/sshd" ]; then
  /usr/sbin/sshd-keygen
fi

exec "$@"
