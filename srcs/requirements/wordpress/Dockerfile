FROM debian:12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.2-fpm \
        php8.2-cli \
        php8.2-mysql \
        php8.2-curl \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-zip \
        php8.2-gd \
        php8.2-intl \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp -sSL \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

WORKDIR /var/www/html

COPY tools/setup_wp.sh /usr/local/bin/setup_wp.sh
RUN chmod +x /usr/local/bin/setup_wp.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup_wp.sh"]
