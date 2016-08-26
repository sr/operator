#!/usr/bin/env bash
set -euo pipefail

# KAFKA_TOPICS="topic1 topic2"
KAFKA_TOPICS="${KAFKA_TOPICS-}"

KAFKA_TOPICS_CMD="/opt/kafka/current/bin/kafka-topics.sh --zookeeper=localhost:2181"

program="${1-}"
if [ "$program" = "supervisord" ] && [ ! -e "/opt/kafka/DOCKER-SETUP" ]; then
  "$@" &
  pid="$!"
  trap "kill -TERM ${pid}" SIGTERM

  # Wait for the list of topics to come back successfully
  ${KAFKA_TOPICS_CMD} --list &>/dev/null

  IFS=' ' read -ra topics_array <<< "$KAFKA_TOPICS"
  if [ "${#topics_array[@]}" -gt 0 ]; then
    for topic in "${topics_array[@]}"; do
      IFS=':' read -ra arr <<<"$topic"

      if ! ${KAFKA_TOPICS_CMD} --list | grep -q "^${arr[0]}$"; then
        while true; do
          echo "Attempting to create topic: ${arr[0]}"
          set +e
          output="$(${KAFKA_TOPICS_CMD} --create --partitions=1 --replication-factor=1 --topic="${arr[0]}")"
          ret="$?"
          set -e

          if [ "$ret" -eq 0 ]; then
            break
          else
            echo "Unable to create topic: $output"
            echo "Retrying ..."
            sleep 1
          fi
        done
      fi
    done
  fi

  touch "/opt/kafka/DOCKER-SETUP"
  wait "$pid"
else
  exec "$@"
fi

