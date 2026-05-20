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

### 2.1 Configuration Files
The project isolates environment variables and daemon configurations to allow modularity:
- **`srcs/.env`**: Contains non-confidential environmental variables such as domain names, database names, network ports, and service user names. If missing, the pre-build stage generates a fully parameterized version automatically.
- **Service Configurations**: Core daemon files (such as NGINX's default `nginx.conf`, MariaDB's `mariadb-server.cnf`, and vsftpd's `vsftpd.conf`) are organized within each service's requirement directory and copied into the respective container image layers during the build process.

### 2.2 Secrets & Passwords Management
To enforce standard security hygiene and comply with the **zero hardcoded password** rule:
- Passwords are dynamically generated using `openssl rand` during the `make setup` phase and stored locally in the `srcs/secrets/` directory.
- The `srcs/secrets/` directory is ignored by Git via `.gitignore` to prevent leakage.
- Docker Compose defines these host files as **Docker Secrets**, securely mounting them into the container runtime filesystem as read-only files under `/run/secrets/<secret_name>`.
- Internal entrypoint shell scripts read these secure mount points on startup to perform database bootstrap operations and WordPress configurations.

### 2.3 Step-by-Step Launch Workflow
1. **Pre-build (`make setup`)**:
   - Creates the required persistent data directories on the host (`/home/${USER}/data`). *Note: The Makefile dynamically resolves this using `/home/$(USER)/data` to ensure seamless portability during evaluation.*
   - Generates the `.env` file if it doesn't exist.
   - Generates random passwords using `openssl` in `srcs/secrets/`.
2. **Build (`make build`)**:
   - Executes `docker compose build`.
   - Each service has its own `Dockerfile` in `srcs/requirements/`.
3. **Up (`make up`)**:
   - Starts the containers in detached mode, relying on healthchecks and service conditions to coordinate the startup sequence (e.g., WordPress waiting until MariaDB is fully healthy).

You can run the entire workflow with a single orchestrator command:
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
As required by the subject, all persistent data is stored in the host's home directory under `/home/<login>/data` (where `<login>` is the username of the student running the stack):
- **MariaDB Data**: `/home/${USER}/data/mariadb`
- **WordPress Files**: `/home/${USER}/data/wordpress`
- **Redis Data**: `/home/${USER}/data/redis`
- **Static Site**: `/home/${USER}/data/static`
- **Monitoring Data**: `/home/${USER}/data/netdata/`

These paths are defined in `srcs/docker-compose.yml` and managed via the `Makefile`.

## 5. Security Architecture
- **Isolation**: All containers run in a private bridge network (`inception_network`).
- **TLS**: NGINX is configured to only accept TLS v1.2 and v1.3.
- **Secrets**: Passwords are never hardcoded in Dockerfiles or the repository. They are passed to containers via Docker Secrets files.
