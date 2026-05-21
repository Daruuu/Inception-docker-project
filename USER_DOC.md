# USER_DOC.md — User Documentation

---

This document explains how to use and access the Inception infrastructure.

## 1. Services Provided

The stack includes the following services:

- **NGINX** — Secure web server with TLS (main entry point)
- **WordPress** — CMS with PHP-FPM
- **MariaDB** — Database
- **Redis** — Cache for better performance
- **FTP Server** — Secure file transfer
- **Adminer** — Database management tool
- **Netdata** — Real-time monitoring
- **Static Site** — Secondary showcase website

## 2. Managing the Project

### Start the infrastructure
```bash
make all
```

### Stop the infrastructure
```bash
make down
```

### Cleanup
```bash
make clean     # Remove containers and networks
make fclean    # Remove everything (including data)
```

### Check status
```bash
make status
```

## 3. Accessing the Services

| Service          | URL                                      | Description                    |
|------------------|------------------------------------------|--------------------------------|
| Main Website     | https://dasalaza.42.fr                   | WordPress site                 |
| WP Admin         | https://dasalaza.42.fr/wp-admin          | WordPress Dashboard            |
| Adminer          | https://dasalaza.42.fr/adminer           | Database manager               |
| Netdata          | https://dasalaza.42.fr/netdata/          | Monitoring dashboard           |
| Static Site      | https://dasalaza.42.fr/static/           | Secondary website              |

> **Note**: Don't forget to add `127.0.0.1 dasalaza.42.fr` to your `/etc/hosts` file and accept the self-signed certificate.

## 4. Credentials and Secrets

Passwords are stored securely:

- Environment variables → `srcs/.env`
- Secrets → `srcs/secrets/`

To view database passwords:
```bash
cat srcs/secrets/db_root_password.txt
cat srcs/secrets/db_password.txt
cat srcs/secrets/wp_admin_password.txt
```

## 5. Adminer Login

| Field        | Value                                                  |
|:-------------|:-------------------------------------------------------|
| **System**   | `MySQL/MariaDB`                                        |
| **Server**   | `mariadb`                                              |
| **Username** | `root` or `SQL_USER` (from `.env`)                     |
| **Password** | Check files in `srcs/secrets/`                         |
| **Database** | Optional at login; use `SQL_DATABASE` from `srcs/.env` |

**Command to see `SQL_USER`:**
```bash
cat srcs/.env | grep SQL_USER
```

**Command to see password:**
```bash
cat srcs/secrets/db_password.txt
cat srcs/secrets/db_root_password.txt
```

## 6. Accessing WordPress Admin

You can log in to the WordPress Dashboard using the following:

**URL:** [https://dasalaza.42.fr/wp-admin](https://dasalaza.42.fr/wp-admin)

| Field        | Value              | Location                             |
|--------------|--------------------|--------------------------------------|
| **Username** | `admin`            | `WP_ADMIN_USER`                      | 
| **Password** | Randomly generated | `srcs/secrets/wp_admin_password.txt` |

**Command to see password:**
```bash
cat srcs/secrets/wp_admin_password.txt
cat srcs/.env  | grep WP_ADMIN_USER
```

---

## 7. Check Service Status (Defense & Inspection Guide)

To verify that the infrastructure is running, follow these step-by-step commands.

### General Status
Ensure all containers are up and displaying `(healthy)`:
```bash
docker ps
```
Or check via the Makefile:
```bash
make status
```

### 🗄️ MariaDB (Database)
1. **Interactive Login, inside de container**:
   ```bash
   docker exec -it mariadb sh
   ```
   ```bash
   docker exec -it mariadb mariadb -u root -p
   ```
   *(Retrieve the root password with `cat srcs/secrets/db_root_password.txt`)*

2. **Automated Root Login & Query**:
   ```bash
   docker exec -it mariadb mariadb -u root -p"$(cat /run/secrets/db_root_password)" -e "SHOW DATABASES; USE inception; SHOW TABLES;"
   ```
   *Expected: You should see the WordPress tables prefixed with `wp_`.*

### WordPress (WP-CLI)
1. **Enter WordPress Container**:
   ```bash
   docker exec -it wordpress sh
   ```
2. **Verify Registered Users**:
   ```bash
   wp user list --allow-root
   ```
3. **Verify Redis Cache Status**:
   ```bash
   wp plugin list --allow-root
   wp redis status --allow-root
   ```

### FTP (File Transfer)
In your `docker-compose.yml`, FTP runs on the host port **`21`** (standard port) using the credentials defined in `.env` (`WP_USER`) and `srcs/secrets/ftp_password.txt`.

1. **Set Up Local Credentials Variables** (for easy copy-paste):
   ```bash
   export FTP_USER=$(grep WP_USER= srcs/.env)
   export FTP_PASS=$(cat srcs/secrets/ftp_password.txt)
   curl -v ftp://$FTP_USER:$FTP_PASS@localhost:2121/
   ```
2. **List Files via FTP**:
   ```bash
   curl -v ftp://$FTP_USER:$FTP_PASS@localhost:2121/
   ```
   
3. **Upload a Test File**:
   ```bash
   echo "Inception FTP Test 2026 - $(date)" > test_ftp.txt

   curl -v -T test_ftp.txt ftp://$FTP_USER:$FTP_PASS@localhost:2121/
   ```
4. **Verify the File Arrived in the WordPress Container**:
   ```bash
   docker exec -it wordpress sh
   
   ls -la /var/www/html/wordpress/test_ftp.txt
   ```
   *Expected: The file should exist and contain "Inception FTP Test 2026".*

### ⚡ Redis (Cache)
1. **Check Connectivity**:
   ```bash
   docker exec -it redis redis-cli ping
   ```
   *Expected: `PONG`*
2. **Monitor Real-Time Cache Activity**:
   ```bash
   docker exec -it redis redis-cli monitor
   ```
   *(Browse the website at [https://dasalaza.42.fr](https://dasalaza.42.fr) to watch cache events stream in real-time).*

### 🔒 Nginx (Web Server)
1. **Test Configuration Syntax**:
   ```bash
   docker exec -it nginx nginx -t
   ```
2. **Verify TLS Certificates**:
   ```bash
   docker exec -it nginx ls -la /etc/nginx/ssl/
   ```
   *Expected: Both `inception.crt` and `inception.key` must be present.*
