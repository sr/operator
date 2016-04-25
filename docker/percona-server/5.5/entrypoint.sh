#!/usr/bin/env bash
set -euo pipefail

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD-pardot07}"

# MYSQL_USERS="user:password:database user2:password2:database2"
MYSQL_USERS="${MYSQL_USERS-}"

program="${1-}"
if [ "$program" = "mysqld" ]; then
  if [ ! -e "/var/lib/mysql/DOCKER-SETUP" ]; then
    "$@" --skip-networking &
    pid="$!"

    for i in {30..0}; do
      if echo "SELECT 1" | mysql --protocol=socket -uroot &> /dev/null; then
        break
      fi

      echo "MySQL is starting ..."
      sleep 1
    done

    if [ "$i" = "0" ]; then
      echo "MySQL failed to start" >&2
      exit 1
    fi

    mysql --protocol=socket -uroot -e "DELETE from mysql.user;"

    IFS=' ' read -ra user_array <<< "$MYSQL_USERS"
    if [ "${#user_array[@]}" -gt 0 ]; then
      for userpass in "${user_array[@]}"; do
        IFS=':' read -ra arr <<< "$userpass"
        mysql --protocol=socket -uroot <<-EOF
          SET @@SESSION.SQL_LOG_BIN=0;

          CREATE DATABASE IF NOT EXISTS ${arr[2]};
          GRANT ALL ON ${arr[2]}.* TO '${arr[0]}'@'%' IDENTIFIED BY '${arr[1]}';
EOF
      done
    fi

    mysql --protocol=socket -uroot <<-EOF
      SET @@SESSION.SQL_LOG_BIN=0;

      CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
      GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
EOF

    if ! kill -s TERM "$pid" || ! wait "$pid"; then
      echo "MySQL process failed to stop cleanly" >&2
      exit 1
    fi

    touch "/var/lib/mysql/DOCKER-SETUP"
  fi
fi

exec "$@"
