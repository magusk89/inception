FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/init_ftp.sh /usr/local/bin/init_ftp.sh
RUN chmod +x /usr/local/bin/init_ftp.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/init_ftp.sh"]
