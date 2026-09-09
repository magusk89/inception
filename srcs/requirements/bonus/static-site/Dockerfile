FROM debian:12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY public/ ./public/
COPY server.js .

EXPOSE 8080

ENTRYPOINT ["node", "server.js"]
