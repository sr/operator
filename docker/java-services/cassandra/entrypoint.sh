#!/usr/bin/env bash
set -euo pipefail
set -x

PROGRAM="${1-}"
if [ "$PROGRAM" = "/usr/sbin/cassandra" ]; then
  IP=$(hostname -i)
  sed -i'' -E "s/.*listen_address:.*/listen_address: \"${IP}\"/" /etc/cassandra/conf/cassandra.yaml
  sed -i'' -E "s/(.*)- seeds:.*/\1- seeds: \"${IP}\"/" /etc/cassandra/conf/cassandra.yaml
fi

exec "$@"
