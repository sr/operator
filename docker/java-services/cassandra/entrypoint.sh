#!/usr/bin/env bash
set -euo pipefail
set -x

PROGRAM="${1-}"
if [ "$PROGRAM" = "/usr/sbin/cassandra" ]; then
  IP=$(hostname -i)
  sed -i'' -E "s/.*listen_address:.*/listen_address: \"${IP}\"/" /etc/cassandra/conf/cassandra.yaml
  sed -i'' -E "s/.*rpc_address:.*/rpc_address: \"${IP}\"/" /etc/cassandra/conf/cassandra.yaml
  sed -i'' -E "s/.*start_rpc:.*/start_rpc: true/" /etc/cassandra/conf/cassandra.yaml
  sed -i'' -E "s/(.*)- seeds:.*/\1- seeds: \"${IP}\"/" /etc/cassandra/conf/cassandra.yaml
  sed -i'' -E "s/.*endpoint_snitch:.*/endpoint_snitch: PropertyFileSnitch/" /etc/cassandra/conf/cassandra.yaml

  cat >/etc/cassandra/conf/cassandra-topology.properties <<EOF
# Cassandra Node IP=Data Center:Rack
${IP}=DEV:RAC1

# default for unknown nodes
default=DEV:RAC
EOF
fi

exec "$@"
