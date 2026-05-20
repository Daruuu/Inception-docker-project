# USER_DOC.md — User Documentation

This document explains how to use and manage the Inception infrastructure.

## 1. Services Provided
The stack provides a full web infrastructure including:
- **NGINX**: Secure web server (TLS v1.2/v1.3) acting as the main entry point.
- **WordPress**: Content Management System (CMS) powered by PHP-FPM.
- **MariaDB**: Relational database for persistent data storage.
- **Redis**: In-memory data structure store used as a cache for WordPress.
- **FTP Server**: Secure file transfer to manage WordPress files.
- **Adminer**: Database management tool accessible via web.
- **Netdata**: Real-time monitoring of system and container performance.
- **Static Site**: A secondary showcase website.

## 2. Managing the Project

### Start the Infrastructure
To build and launch all services in the background:
```bash
make all
```

### Stop the Infrastructure
To stop all running containers without deleting data:
```bash
make down
```

### Clean Up
To remove containers, networks, and images:
```bash
make clean
```
To remove everything, including **persistent data and secrets**:
```bash
make fclean
```

## 3. Accessing the Services
Once the project is running, you can access the following via your browser:

| Service          | URL                                                                | Description           |
|:-----------------|:-------------------------------------------------------------------|:----------------------|
| **Main Website** | [https://dasalaza.42.fr](https://dasalaza.42.fr)                   | Your WordPress site.  |
| **WP Admin**     | [https://dasalaza.42.fr/wp-admin](https://dasalaza.42.fr/wp-admin) | WordPress Dashboard.  |
| **Adminer**      | [https://dasalaza.42.fr/adminer](https://dasalaza.42.fr/adminer)   | Database management.  |
| **Netdata**      | [https://dasalaza.42.fr/netdata/](https://dasalaza.42.fr/netdata/) | Monitoring dashboard. |
| **Static Site**  | [https://dasalaza.42.fr/static/](https://dasalaza.42.fr/static/)   | Webserver project.    |

### Opening Adminer

Before using Adminer, ensure the stack is running:

```bash
make all
```

You can confirm that the `adminer` and `mariadb` containers are up with:

```bash
make status
```

Then open Adminer in your browser:

**[https://dasalaza.42.fr/adminer](https://dasalaza.42.fr/adminer)**

Requirements:

- Add a hosts entry pointing your domain to the machine running the stack (for example `127.0.0.1 dasalaza.42.fr` in `/etc/hosts`, or your VM IP when evaluating on a 42 machine).
- Accept the self-signed TLS certificate if your browser warns about it.

Adminer is served by NGINX at the `/adminer` path and proxies requests to the `adminer` container.

### Logging in to Adminer

On the Adminer login form, use **MySQL** as the system and **`mariadb`** as the server (the Docker Compose service name on the internal network — do not use `localhost`).

| Field        | Value                                                  |
|:-------------|:-------------------------------------------------------|
| **System**   | `MySQL`                                                |
| **Server**   | `mariadb`                                              |
| **Username** | `dasalaza`                                             |
| **Database** | Optional at login; use `SQL_DATABASE` from `srcs/.env` |

You can sign in as **root** (full access) or as the **application 
user** (access limited to the WordPress database). 
Usernames and database names come from `srcs/.env`; passwords come from `srcs/secrets/`.

#### Login as root

| Field        | Where to find it                    |
|:-------------|:------------------------------------|
| **System**   | `MySQL`                             |
| **Server**   | `mariadb`                           |
| **Username** | `root`                              |
| **Password** | `srcs/secrets/db_root_password.txt` |

```bash
cat srcs/secrets/db_root_password.txt
```

#### Login as the application user

| Field        | Where to find it               |
|:-------------|:-------------------------------|
| **Username** | `SQL_USER` in `srcs/.env`      |
| **Password** | `srcs/secrets/db_password.txt` |
| **Database** | `SQL_DATABASE` in `srcs/.env`  |

```bash
grep SQL_USER srcs/.env
grep SQL_DATABASE srcs/.env
cat srcs/secrets/db_password.txt
```

#### Quick reference

| What you need   | File / variable                          |
|:----------------|:-----------------------------------------|
| Database name   | `SQL_DATABASE` → `srcs/.env`             |
| App DB username | `SQL_USER` → `srcs/.env`                 |
| App DB password | `db_password.txt` → `srcs/secrets/`      |
| Root password   | `db_root_password.txt` → `srcs/secrets/` |

These secrets are created on first `make setup` / `make all`. If login fails after changing secrets, you may need `make fclean` and `make all` to reinitialize MariaDB with the new passwords.

## 4. Credentials and Secrets
For security reasons, passwords are not stored in the repository. You can find them in:
- **Environment Variables**: Located in `srcs/.env`.
- **Docker Secrets**: Generated at runtime in `srcs/secrets/`. These are mapped inside the containers to `/run/secrets/`.

To view your generated database passwords:
```bash
cat srcs/secrets/db_password.txt
cat srcs/secrets/db_root_password.txt
cat srcs/secrets/wp_admin_password.txt
```

## 5. Checking Service Health
To verify that all services are running correctly:
```bash
make status
```
Or use the standard Docker command:
```bash
docker ps
```
A "healthy" status in `docker ps` indicates that the internal health checks (defined in `docker-compose.yml`) have passed.

## 6. Testing Redis and MariaDB

Run these commands from the **project root** (where the `Makefile` is). They use `docker compose -f srcs/docker-compose.yml`; adjust the path if your layout differs.

### Testing MariaDB

#### 1. Container and health check

Confirm `mariadb` is running and **healthy**:

```bash
docker compose -f srcs/docker-compose.yml ps mariadb
```

The built-in health check runs `mysqladmin ping` as `root` inside the container.

#### 2. List databases and WordPress tables

MariaDB reads `SQL_DATABASE` and `SQL_USER` from `srcs/.env`. Passwords come from Docker secrets inside the container.

```bash
# List databases (as root)
docker compose -f srcs/docker-compose.yml exec mariadb sh -c \
  'mysql -u root -p"$(cat /run/secrets/db_root_password | tr -d "\n")" -e "SHOW DATABASES;"'

# List tables in the WordPress database (as app user)
docker compose -f srcs/docker-compose.yml exec mariadb sh -c \
  'mysql -u "$SQL_USER" -p"$(cat /run/secrets/db_password | tr -d "\n")" "$SQL_DATABASE" -e "SHOW TABLES;"'
```

After WordPress is installed, you should see tables with the `wp_` prefix (for example `wp_posts`, `wp_options`, `wp_users`).

#### 3. Verify WordPress can read and write data

From the **wordpress** container:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress wp db check --allow-root
```

Create or edit a post in [WP Admin](https://dasalaza.42.fr/wp-admin), then confirm it is stored in MariaDB:

```bash
docker compose -f srcs/docker-compose.yml exec mariadb sh -c \
  'mysql -u "$SQL_USER" -p"$(cat /run/secrets/db_password | tr -d "\n")" "$SQL_DATABASE" \
  -e "SELECT ID, post_title, post_status FROM wp_posts WHERE post_type = '\''post'\'' ORDER BY ID DESC LIMIT 5;"'
```

You can also browse tables in [Adminer](#logging-in-to-adminer) under the `SQL_DATABASE` from `srcs/.env`.

#### 4. Verify persistence (data survives a restart)

1. Note a value in the database (for example a post title from the query above).
2. Stop the stack: `make down`
3. Start again: `make up`
4. Run the `SELECT` query again — the row should still be there (data is stored under `/home/$USER/data/mariadb` on the host).

---

### Testing Redis

WordPress uses the **Redis Object Cache** plugin (`redis-cache`). On first install, the wordpress entrypoint sets `WP_REDIS_HOST` to `redis` and runs `wp redis enable` when the Redis host is reachable.

#### 1. Container and basic connectivity

```bash
docker compose -f srcs/docker-compose.yml ps redis
docker compose -f srcs/docker-compose.yml exec redis redis-cli ping
```

Expected response: `PONG`.

#### 2. Check Redis from WordPress

```bash
docker compose -f srcs/docker-compose.yml exec wordpress wp redis status --allow-root
```

A working setup typically reports that Redis is **reachable** and the object cache is **enabled**.

Optional details:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress wp redis info --allow-root
```

#### 3. Confirm Redis is storing cache data

1. Load the site a few times in the browser: [https://dasalaza.42.fr](https://dasalaza.42.fr)
2. Inspect keys and memory usage:

```bash
# Number of keys in the current database
docker compose -f srcs/docker-compose.yml exec redis redis-cli DBSIZE

# Sample keys (WordPress / redis-cache often use prefixed names)
docker compose -f srcs/docker-compose.yml exec redis redis-cli KEYS '*'

# Basic stats (hits, misses, memory)
docker compose -f srcs/docker-compose.yml exec redis redis-cli INFO stats
```

After traffic to the site, `DBSIZE` should be **greater than 0** and `KEYS '*'` should list cache entries. `INFO stats` helps confirm reads/writes (`keyspace_hits`, `keyspace_misses`).

#### 4. Functional cache test (optional)

```bash
# Flush Redis, load the site, then check DBSIZE grows again
docker compose -f srcs/docker-compose.yml exec redis redis-cli FLUSHALL
docker compose -f srcs/docker-compose.yml exec redis redis-cli DBSIZE
# Visit https://dasalaza.42.fr in the browser, then:
docker compose -f srcs/docker-compose.yml exec redis redis-cli DBSIZE
```

The second `DBSIZE` should be higher than right after `FLUSHALL`, which shows WordPress is repopulating the cache.

#### 5. Troubleshooting

| Symptom                      | What to check                                                                                                                                    |
|:-----------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------|
| `redis` not **healthy**      | `docker compose -f srcs/docker-compose.yml logs redis`                                                                                           |
| `wp redis status` fails      | WordPress may have been installed before Redis was up; check `docker compose -f srcs/docker-compose.yml logs wordpress` for Redis setup messages |
| `DBSIZE` stays `0`           | Browse the site to generate cache; confirm `wp redis status` shows cache enabled                                                                 |
| MariaDB has no `wp_*` tables | Wait until `wordpress` is **healthy**; check `docker compose -f srcs/docker-compose.yml logs wordpress`                                          |

For interactive shells: `make mariadb` or `make wordpress` (see `Makefile`).
