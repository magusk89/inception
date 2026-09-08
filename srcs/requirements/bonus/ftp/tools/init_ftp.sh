#!/bin/sh
set -e

FTP_USER=$(sed -n '1p' /run/secrets/ftp_credentials)
FTP_PASS=$(sed -n '2p' /run/secrets/ftp_credentials)

touch /etc/vsftpd.user_list

mkdir -p /var/run/vsftpd/empty
chmod 0755 /var/run/vsftpd/empty
chown root:root /var/run/vsftpd/empty

if ! id "${FTP_USER}"; then
    adduser --disabled-password --gecos "" --home /var/www/html "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASS}" | chpasswd
    echo "${FTP_USER}" >> /etc/vsftpd.user_list
fi

chown -R "${FTP_USER}":"${FTP_USER}" /var/www/html

exec /usr/sbin/vsftpd /etc/vsftpd.conf
