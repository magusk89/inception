# Developer documentation

## Setting up the environment from scratch

Prerequisites: a VM running Debian, Docker Engine, and the Docker
Compose plugin.

1. Clone the repository.
2. `secrets/` and `srcs/.env` already contain working values for local
   testing — replace them with your own before any real submission.
3. Add `127.0.0.1 alebarbo.42.fr` to `/etc/hosts` on the VM.

## Building and launching with the Makefile / Compose

```
make setup
make up
```

`make` (the default target) runs both in sequence.

## Managing containers and volumes

The Makefile pins the Compose project name to `inception`, so use the
same flag when running Compose commands directly:

```
docker compose -p inception -f srcs/docker-compose.yml ps
docker compose -p inception -f srcs/docker-compose.yml logs -f <service>
docker compose -p inception -f srcs/docker-compose.yml exec mariadb sh
docker volume inspect inception_db_data
```

To rebuild a single service after editing its Dockerfile:

```
docker compose -p inception -f srcs/docker-compose.yml up --build -d <service>
```

## Where data is stored and how it persists

The two named volumes (`db_data`, `wp_data`) use `driver_opts` pointing
at `/home/alebarbo/data/db` and `/home/alebarbo/data/wordpress` on the
host. `docker compose down` (without `-v`) leaves them untouched. Only
`make fclean` removes them, along with the host directories' contents —
use it whenever you need a guaranteed clean re-bootstrap, for example
after changing database credentials or entrypoint scripts.

## Enabling the bonus part

Bonus services live in `srcs/docker-compose.bonus.yml`, a separate,
independently valid Compose file layered on top of the mandatory one —
they are not started by the default `make` target, since the subject
only evaluates bonus once the mandatory part is confirmed perfect.

Once mandatory is verified working:

```
make bonus
```

which runs:

```
docker compose -p inception -f srcs/docker-compose.yml -f srcs/docker-compose.bonus.yml up --build -d
```

Compose merges both files into one configuration by name: the bonus
file adds new services and the `ftp_credentials` secret, reusing the
`inception` network and `wp_data` volume already declared in the main
file. `secrets/ftp_credentials.txt` must exist for the `ftp` service to
build — it ships with a working value for local testing, same as the
mandatory secrets.

The bonus file also extends the existing `nginx` service rather than
adding a new one: it appends a second published port (`8443`) and
mounts `monilite.conf` into `/etc/nginx/conf.d/`, which the mandatory
`nginx.conf` already includes via `include conf.d/*.conf;` — a line
that's a no-op when that directory is empty (the default, mandatory-only
case) and picks up the extra server block only once bonus mounts a file
there. Compose appends `ports`/`volumes` entries across files by target
rather than replacing them (confirmed against Docker's own compose-file
merge documentation), so the mandatory `443:443` mapping and `wp_data`
mount on `nginx` are untouched by enabling bonus.

To manage or tear down bonus containers specifically, pass both `-f`
flags to any Compose command, since `down`/`logs`/`ps` need to know
about both files to see the bonus services:

```
docker compose -p inception -f srcs/docker-compose.yml -f srcs/docker-compose.bonus.yml down
docker compose -p inception -f srcs/docker-compose.yml -f srcs/docker-compose.bonus.yml logs -f ftp
```
