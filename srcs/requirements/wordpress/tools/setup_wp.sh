#!/bin/sh
set -e

WP_PATH="/var/www/html"

: "${DOMAIN_NAME:?DOMAIN_NAME not set}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE not set}"
: "${MYSQL_USER:?MYSQL_USER not set}"
: "${WP_TITLE:?WP_TITLE not set}"

DB_PASSWORD=$(tr -d '\r\n' < /run/secrets/db_password)
WP_ADMIN_USER=$(sed -n '1p' /run/secrets/credentials | tr -d '\r\n')
WP_ADMIN_PASS=$(sed -n '2p' /run/secrets/credentials | tr -d '\r\n')
WP_USER2=$(sed -n '3p' /run/secrets/credentials | tr -d '\r\n')
WP_USER2_PASS=$(sed -n '4p' /run/secrets/credentials | tr -d '\r\n')

case "$(echo "$WP_ADMIN_USER" | tr '[:upper:]' '[:lower:]')" in
    *admin*)
        echo "admin username cannot contain admin"
        exit 1
        ;;
esac

echo "waiting for database"
i=0
until php8.2 -r "exit(@fsockopen('mariadb', 3306) ? 0 : 1);"; do
    i=$((i + 1))
    if [ "$i" -ge 60 ]; then
        echo "database not reachable after 60s"
        exit 1
    fi
    sleep 1
done
echo "database reachable"

mkdir -p /run/php

cd "${WP_PATH}"

if [ ! -f "${WP_PATH}/wp-settings.php" ]; then
    echo "downloading wordpress core"
    wp core download --allow-root
fi

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo "writing wp-config.php"
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb:3306 \
        --allow-root
fi

if ! wp core is-installed --allow-root; then
    echo "running install"
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="admin@${DOMAIN_NAME}" \
        --allow-root

    wp user create "${WP_USER2}" "editor@${DOMAIN_NAME}" \
        --role=editor \
        --user_pass="${WP_USER2_PASS}" \
        --allow-root
    echo "wordpress installed"
else
    echo "already installed"
fi

chown -R www-data:www-data "${WP_PATH}"

exec php-fpm8.2 -F -O
