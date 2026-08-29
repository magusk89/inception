*This project has been created as part of the 42 curriculum by alebarbo.*

# Inception

## Description

Inception sets up a small self-contained web infrastructure using Docker
Compose: an NGINX reverse proxy terminating TLS, a WordPress site running
on php-fpm, and a MariaDB database — each in its own container, built from
scratch with a dedicated Dockerfile, connected over a private Docker
network, and backed by two persistent named volumes.

## Instructions

1. Add `127.0.0.1 alebarbo.42.fr` to `/etc/hosts` on the VM.
2. Run `make` from the repository root.
3. Visit `https://alebarbo.42.fr` (accept the self-signed certificate warning).

See `USER_DOC.md` for day-to-day usage and `DEV_DOC.md` for the full
development/build workflow.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Compose file reference](https://docs.docker.com/reference/compose-file/)
- [Debian release policy](https://www.debian.org/releases/)
- [WP-CLI documentation](https://wp-cli.org/)
- [NGINX documentation](https://nginx.org/en/docs/)

AI assistance was used to generate this README and the DEV_DOC and USER_DOC files.

## Project description: design choices

**Why Debian for the base image** — Debian was chosen over Alpine for
package maturity and glibc compatibility: MariaDB, PHP, and WP-CLI all
ship as well-tested `apt` packages with predictable version numbers.

**Virtual Machines vs Docker** — a VM virtualises an entire OS on top of
a hypervisor, which is heavy but fully isolated. A container shares the
host kernel and only packages the application plus its userspace
dependencies, which makes it far lighter and faster to start. This
project uses one VM as the host, and Docker containers inside it for
each service.

**Secrets vs Environment Variables** — environment variables are visible
in plaintext via `docker inspect` and can leak into image layers or
logs. Docker secrets are mounted as files only inside the container's
filesystem and are never baked into an image layer. This project uses
`.env` for non-sensitive configuration and Docker secrets for passwords.

**Docker Network vs Host Network** — host networking removes network
isolation entirely and every port is exposed. A custom bridge network
keeps containers isolated from the host and lets them reach each other
by service name through Docker's embedded DNS. This project uses a
single custom bridge network (`inception`) and never `network: host`.

**Docker Volumes vs Bind Mounts** — a bind mount points directly at an
arbitrary host path with no lifecycle management. A named volume is
managed by Docker end-to-end and can still be pinned to a specific host
path via `driver_opts`. This project uses two named volumes, `db_data`
and `wp_data`, both pinned to `/home/alebarbo/data/`.

## Bonus

The bonus part adds five extra services on top of the mandatory stack,
each with its own Dockerfile and, where relevant, its own volume:

- **Redis** — an object cache for WordPress, reducing repeated database
  queries.
- **FTP** (vsftpd) — mounts the same `wp_data` volume as WordPress and
  NGINX, so files uploaded over FTP appear on the live site immediately.
- **Static site** — a small Node.js site (no PHP), served independently
  of WordPress.
- **Adminer** — a single-file web UI for browsing the MariaDB database
  directly.
- **MONILite** — the "service of your choice" slot. A small, MIT-licensed
  Python system monitor ([github.com/zhao4hua4/MONILite](https://github.com/zhao4hua4/MONILite))
  that reports CPU, memory, and disk usage for the host over an HTTP API
  and a bundled dashboard.

**Why MONILite:** its own documentation specifically recommends running
it behind an NGINX TLS reverse proxy — exactly the pattern this project
already uses for WordPress. Rather than publish its port directly like
the other bonus services, NGINX reverse-proxies to it on a second port
(8443), reusing the same TLS certificate already generated for the
mandatory site. It's also directly useful for this project specifically:
a way to actually watch the VM's resource usage while the stack runs,
which is the kind of thing you'd otherwise have to SSH in and check
manually.

Bonus services are not started by the default `make` target, since the
subject only evaluates the bonus part once the mandatory part is
confirmed perfect. Bring them up with `make bonus` — see `DEV_DOC.md`
for exact commands and `USER_DOC.md` for how to access each one.
