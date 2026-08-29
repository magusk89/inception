# User documentation

## What services does this stack provide?

| Service | What it does |
|---|---|
| NGINX | Serves the website over HTTPS, the only door into the stack |
| WordPress | The site itself — pages, posts, admin panel |
| MariaDB | Stores all WordPress content (posts, users, settings) |

## Starting and stopping the project

```
make        # builds everything and starts the stack in the background
make down   # stops and removes the containers (data is kept)
make re     # full reset: wipes containers, images, and stored data
```

## Accessing the website and the admin panel

- Website: `https://alebarbo.42.fr`
- Admin panel: `https://alebarbo.42.fr/wp-admin`

Your browser will warn about the certificate because it's self-signed —
this is expected, accept the warning to continue.

## Locating and managing credentials

Credentials live in `secrets/` at the repository root, never in Git:

- `secrets/credentials.txt` — WordPress admin and second user, one per line
- `secrets/db_password.txt` — WordPress database user password
- `secrets/db_root_password.txt` — MariaDB root password

## Checking that services are running correctly

```
make ps
make logs
docker logs nginx
docker logs wordpress
docker logs mariadb
```

All three should show `Up` in `make ps`.

## Bonus services

Bonus services only start once you run `make bonus` — they're separate
from the mandatory `make`, since the subject only assesses bonus after
mandatory is confirmed perfect. Once running:

- **Redis** — works automatically in the background once WordPress's
  object-cache plugin points at it; no direct interaction needed.
- **FTP** — connect with any FTP client to the VM's IP address on port
  21, using the username and password in `secrets/ftp_credentials.txt`.
  If your client needs a passive port range, it's 21100–21110.
- **Static site** — visit `http://<VM IP>:8080` directly. It runs
  outside NGINX/TLS in this setup, so it's plain HTTP.
- **Adminer** — visit `http://<VM IP>:8081`, log in with server
  `mariadb` and the database credentials from `secrets/db_password.txt`
  and `srcs/.env`.
- **MONILite** — visit `https://alebarbo.42.fr:8443` (same self-signed
  certificate warning as the main site). Shows live CPU, memory, and
  disk usage with history charts. No login — anyone who can reach that
  port can view it.

Check bonus containers the same way as the mandatory ones:

```
docker compose -p inception -f srcs/docker-compose.yml -f srcs/docker-compose.bonus.yml ps
```
