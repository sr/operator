#!/usr/bin/env bash
set -euo pipefail

MYSQL_SOCKET_FILE="${MYSQL_SOCKET_FILE-/var/lib/mysql/mysql.sock}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD-pardot07}"

# MYSQL_USERS="user:password:database user2:password2:database2"
MYSQL_USERS="${MYSQL_USERS-}"

program="${1-}"
if [ "$program" = "mysqld" ]; then
  if [ ! -e "/var/lib/mysql/DOCKER-SETUP" ]; then
    echo "$(date) Initializing MySQL ..."
    if ! mysqld --initialize-insecure; then
      echo "Failed to initialize MySQL database" 2>&1
      cat /var/log/mysql/error.log
      exit 1
    fi
  fi

  "$@" &
  pid="$!"
  shutdown() {
    echo "$(date) MySQL is shutting down ..."
    mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" --protocol=tcp -h127.0.0.1 shutdown
    wait "$pid"
  }
  trap shutdown TERM INT

  if [ ! -e "/var/lib/mysql/DOCKER-SETUP" ]; then
    for i in {30..0}; do
      if echo "SELECT 1" | mysql --socket="$MYSQL_SOCKET_FILE" --protocol=socket -uroot &> /dev/null; then
        break
      fi

      echo "$(date) MySQL is starting ..."
      sleep 1
    done

    if [ "$i" = "0" ]; then
      echo "$(date) MySQL failed to start" >&2
      cat /var/log/mysql/error.log
      exit 1
    else
      echo "$(date) MySQL started!"
    fi

    mysql --socket="$MYSQL_SOCKET_FILE" --protocol=socket -uroot -e "DELETE from mysql.user;"

    IFS=' ' read -ra user_array <<< "$MYSQL_USERS"
    if [ "${#user_array[@]}" -gt 0 ]; then
      for userpass in "${user_array[@]}"; do
        IFS=':' read -ra arr <<< "$userpass"

        if [ "${arr[2]}" != "*" ]; then
          mysql --socket="$MYSQL_SOCKET_FILE" --protocol=socket -uroot <<-EOF
            CREATE DATABASE IF NOT EXISTS ${arr[2]};
EOF
        fi

        mysql --socket="$MYSQL_SOCKET_FILE" --protocol=socket -uroot <<-EOF
          SET @@SESSION.SQL_LOG_BIN=0;

          GRANT ALL ON ${arr[2]}.* TO '${arr[0]}'@'%' IDENTIFIED BY '${arr[1]}';
EOF
      done
    fi

    mysql --socket="$MYSQL_SOCKET_FILE" --protocol=socket -uroot <<-EOF
      SET @@SESSION.SQL_LOG_BIN=0;

      CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
      GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
      FLUSH PRIVILEGES;
EOF
  fi

  touch "/var/lib/mysql/DOCKER-SETUP"
  wait "$pid"
else
  exec "$@"
fi

