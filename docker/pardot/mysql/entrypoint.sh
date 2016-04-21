#!/usr/bin/env bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

if [ "$1" = "mysqld" ]; then
  if [ ! -e "/var/lib/mysql/ROOT-PASSWORD-SET" ]; then
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

    mysql --protocol=socket -uroot <<-EOF
      SET @@SESSION.SQL_LOG_BIN=0;

      DELETE from mysql.user;

      CREATE USER 'root'@'%' IDENTIFIED BY 'pardot07';
      GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;

      CREATE USER 'pardot'@'%' IDENTIFIED BY 'pardot';
      GRANT ALL ON *.* TO 'pardot'@'%';

      CREATE USER 'pifunctional'@'%' IDENTIFIED BY 'mysql';
      GRANT ALL ON *.* TO 'pifunctional'@'%';
EOF

    if ! kill -s TERM "$pid" || ! wait "$pid"; then
      echo "MySQL process failed to stop cleanly" >&2
      exit 1
    fi

    touch "/var/lib/mysql/ROOT-PASSWORD-SET"
  fi
fi

exec "$@"
