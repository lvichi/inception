#!/bin/bash

# Copy the init.sql file to gain access to it
if [ -f /etc/mysql/init.sql ]; then
  export MYSQL_ROOT_PASSWORD="$(< /run/secrets/db_root_password)" && \
  export MYSQL_PASSWORD="$(< /run/secrets/db_password)" && \
  envsubst < /etc/mysql/init.sql > /tmp/init.sql
  chown mysql:mysql /tmp/init.sql
  chmod 660       /tmp/init.sql
else
  echo "No init.sql file found in /etc/mysql"
  exit 1
fi

exec mariadbd