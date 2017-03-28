#!/usr/bin/env bash
set -euo pipefail

RMUX_SOCKETS=(
  "rmux-master.sock"
  "rmux-slave.sock"
  "rmux-rules-master.sock"
  "rmux-rules-slave.sock"
)

for socket in "${RMUX_SOCKETS[@]}"; do
  rm -f "/var/lib/rmux/${socket}"
done

exec "$@"
