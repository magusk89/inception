FROM debian:12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/monilite-venv \
    && /opt/monilite-venv/bin/pip install --no-cache-dir monilite

EXPOSE 8000

ENTRYPOINT ["/opt/monilite-venv/bin/monilite", "serve", "--host", "0.0.0.0", "--port", "8000", "--no-gpu"]
