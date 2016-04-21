#!/usr/bin/env bash
set -euo pipefail

RMUX_SOCKETS=(
  "rmux-master.sock"
  "rmux-slave.sock"
  "rmux-rules-master.sock"
  "rmux-rules-slave.sock"
)

for socket in "${RMUX_SOCKETS[@]}"; do
  ln -sf "/var/lib/rmux/${socket}" "/tmp/${socket}"
done

mkdir -p /app/cache
chown -R apache:apache /app/cache
chown -R apache:apache /app/log

mkdir -p /tmp/httpd.core
chown -R apache:apache /tmp/httpd.core
chmod 0700 /tmp/httpd.core

exec "$@"
