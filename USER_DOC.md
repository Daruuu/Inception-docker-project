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

| Service | URL | Description |
| :--- | :--- | :--- |
| **Main Website** | [https://dasalaza.42.fr](https://dasalaza.42.fr) | Your WordPress site. |
| **WP Admin** | [https://dasalaza.42.fr/wp-admin](https://dasalaza.42.fr/wp-admin) | WordPress Dashboard. |
| **Adminer** | [https://dasalaza.42.fr/adminer](https://dasalaza.42.fr/adminer) | Database management. |
| **Netdata** | [https://dasalaza.42.fr/netdata/](https://dasalaza.42.fr/netdata/) | Monitoring dashboard. |
| **Static Site** | [https://dasalaza.42.fr/static/](https://dasalaza.42.fr/static/) | Secondary website. |

## 4. Credentials and Secrets
For security reasons, passwords are not stored in the repository. You can find them in:
- **Environment Variables**: Located in `srcs/.env`.
- **Docker Secrets**: Generated at runtime in `srcs/secrets/`. These are mapped inside the containers to `/run/secrets/`.

To view your generated passwords:
```bash
cat srcs/secrets/db_password.txt
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
