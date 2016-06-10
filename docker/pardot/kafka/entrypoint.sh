#!/usr/bin/env bash
set -eumo pipefail

# KAFKA_TOPICS="topic1 topic2"
KAFKA_TOPICS="${KAFKA_TOPICS-}"

KAFKA_TOPICS_CMD="/opt/kafka/current/bin/kafka-topics.sh --zookeeper=localhost:2181"

program="${1-}"
if [ "$program" = "supervisord" ] && [ ! -e "/opt/kafka/DOCKER-SETUP" ]; then
  "$@" &

  # Wait for the list of topics to come back successfully
  ${KAFKA_TOPICS_CMD} --list

  IFS=' ' read -ra topics_array <<< "$KAFKA_TOPICS"
  if [ "${#topics_array[@]}" -gt 0 ]; then
    for topic in "${topics_array[@]}"; do
      IFS=':' read -ra arr <<< "$topic"

      if ! ${KAFKA_TOPICS_CMD} --list | grep -q "^${arr[0]}$"; then
        ${KAFKA_TOPICS_CMD} --create --partitions=1 --replication-factor=1 --topic="${arr[0]}"
      fi
    done
  fi

  touch "/opt/kafka/DOCKER-SETUP"
  fg %1
else
  exec "$@"
fi

