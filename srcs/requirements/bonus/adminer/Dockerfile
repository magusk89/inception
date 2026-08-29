FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.2-cli \
        php8.2-mysql \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer \
    && curl -o /var/www/adminer/index.php -sSL \
        https://www.adminer.org/latest.php

EXPOSE 8081

CMD ["php8.2", "-S", "0.0.0.0:8081", "-t", "/var/www/adminer"]
