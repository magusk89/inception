#!/bin/sh
set -e

DB_DATA_DIR="/var/lib/mysql"

DB_ROOT_PASSWORD=$(sed -n '1p' /run/secrets/db_root_password)
DB_PASSWORD=$(sed -n '1p' /run/secrets/db_password)

: "${MYSQL_DATABASE:?MYSQL_DATABASE not set}"
: "${MYSQL_USER:?MYSQL_USER not set}"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "${DB_DATA_DIR}/mysql" ]; then
    echo "initialising data directory"
    mariadb-install-db --user=mysql --datadir="${DB_DATA_DIR}"
fi

mysqld --user=mysql --datadir="${DB_DATA_DIR}" --skip-networking &
TMP_PID=$!

i=0
until mysqladmin --user=root --password="${DB_ROOT_PASSWORD}" ping; do
    i=$((i + 1))
    if [ "$i" -ge 30 ]; then
        echo "bootstrap mysqld did not come up"
        exit 1
    fi
    sleep 1
done

mysql --user=root --password="${DB_ROOT_PASSWORD}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

mysqladmin --user=root --password="${DB_ROOT_PASSWORD}" shutdown
wait "${TMP_PID}"

exec mysqld --user=mysql --datadir="${DB_DATA_DIR}" --bind-address=0.0.0.0
