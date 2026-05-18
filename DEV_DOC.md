# DEV_DOC.md — Developer Documentation

This document describes the technical implementation and development workflow for the Inception project.

## 1. Environment Setup
To develop or modify this project, you need:
- **Operating System**: A Linux-based Virtual Machine (Debian or Alpine recommended).
- **Docker**: Version 20.10+ with `docker compose` plugin.
- **Tools**: `make`, `openssl`, and `git`.

### Hosts Configuration
Add the following line to your `/etc/hosts` file to resolve the domain locally:
```text
127.0.0.1 dasalaza.42.fr
```

## 2. Build and Launch Process
The project uses a `Makefile` to orchestrate the creation of the environment.

### Step-by-Step Workflow:
1. **Pre-build (`make setup`)**:
   - Creates required directories in the host (`/home/daruuu/data`).
   - Generates the `.env` file if it doesn't exist.
   - Generates random passwords using `openssl` in `srcs/secrets/`.
2. **Build (`make build`)**:
   - Executes `docker compose build`.
   - Each service has its own `Dockerfile` in `srcs/requirements/`.
3. **Up (`make up`)**:
   - Starts the containers in detached mode.

You can run all steps at once with:
```bash
make all
```

## 3. Management and Debugging Commands

| Command        | Action                                     |
|:---------------|:-------------------------------------------|
| `make logs`    | Stream logs from all containers.           |
| `make ps`      | List containers and their status.          |
| `make re`      | Complete rebuild (fclean + all).           |
| `make nginx`   | Open a shell inside the NGINX container.   |
| `make mariadb` | Open a shell inside the MariaDB container. |

## 4. Data Persistence
Data is persisted using **Docker Named Volumes** configured with a bind-mount driver. This ensures data remains on the host even if containers are deleted.

### Host Storage Locations:
- **MariaDB Data**: `/home/daruuu/data/mariadb`
- **WordPress Files**: `/home/daruuu/data/wordpress`
- **Redis Data**: `/home/daruuu/data/redis`
- **Static Site**: `/home/daruuu/data/static`
- **Monitoring Data**: `/home/daruuu/data/netdata/`

These paths are defined in `srcs/docker-compose.yml` and managed via the `Makefile`.

## 5. Security Architecture
- **Isolation**: All containers run in a private bridge network (`inception_network`).
- **TLS**: NGINX is configured to only accept TLS v1.2 and v1.3.
- **Secrets**: Passwords are never hardcoded in Dockerfiles or the repository. They are passed to containers via Docker Secrets files.
