*This project has been created as part of the 42 curriculum by dasalaza.*
# Inception

## Description
This project aims to broaden my knowledge of system administration by using **Docker**. The main objective is to set up a complete and secure web infrastructure composed of three services: **Nginx** (as a reverse proxy with TLS), **WordPress** (with PHP-FPM), and **MariaDB**, all orchestrated through **Docker Compose**.

### Why Docker?
Docker was chosen because it allows us to create **lightweight, portable, and isolated**
environments using container technology. Unlike traditional virtual machine, Docker container share the host kernel, which provides:

- **Much better performance** (near-native speed)
- **Lower resource consumption** (CPU, RAM, and disk)
- **Faster startup and deployment**
- **Great portability** between different Linux distributions, development, and production environments

Docker excels at process isolation at the kernel level through **namespaces** and **cgroups**, providing an excellent balance between
**security, performance, and efficiency**. Unlike virtual machines, containers do not emulate a full operating system, which results in
significantly lower resource consumption and near-native performance.
<br><br>This project allowed me to deeply **understand** key containerization **concepts**, such as image building, multi-container orchestration
with Docker Compose, persistent storage management with volumes, and networking between services.
It also highlighted the importance of __designing__ a *solid and scalable infrastructure* for any project, along with modern
system administration best practices including security hardening, environment separation, and infrastructure as code.

### Sources & Project Structure
All deployment configurations and build assets are placed in the `srcs` folder, keeping the root of the repository clean:
```text
├── Makefile                     # Root orchestrator (setup, all, build, up, clean, fclean ...)
├── USER_DOC.md                  # Operational guide for end users and evaluators
├── DEV_DOC.md                   # Setup and maintenance guide for developers
└── srcs/
    ├── .env                     # Non-confidential environment configuration
    ├── docker-compose.yml       # Stack orchestration (services, networks, volumes)
    └── requirements/            # Dedicated directories for each service
        ├── mariadb/             # MariaDB Dockerfile, configs, and setup scripts
        ├── nginx/               # NGINX Dockerfile, TLS configuration, and SSL certs
        ├── wordpress/           # WordPress & PHP-FPM setup using wp-cli
        └── bonus/               # Bonus services
            ├── adminer/         # Database web administration panel
            ├── ftp/             # Vsftpd server container for file management
            ├── netdata/         # Real-time monitoring dashboard
            ├── redis/           # Redis Cache container for WP object caching
            └── static_site/     # Secondary HTML showcase website
```

### Key Design Choices
1. **Security-First Base Images**: Built exclusively on top of the penultimate stable version of Alpine Linux, reducing the attack surface.
2. **Process Management (PID 1)**: Avoided infinite sleep/loop hacks. Services run in the foreground, letting Docker manage life-cycles and signal propagation correctly.
3. **Zero Hardcoded Passwords**: Implemented Docker Secrets (`/run/secrets/`) for database, WordPress, and FTP credentials.
4. **Dedicated Networks**: Custom internal bridge network isolates inter-container communications from the host network namespace.
5. **Persistence**: Using Docker named volumes stored at `/home/${USER}/data`.
6. **Security**: Environment variables and Docker secrets are used to handle credentials, ensuring no passwords are hardcoded in the images.


### Key Features

#### Mandatory
- **Nginx**: The only entry point to the infrastructure, configured with _TLSv1.2/v1.3_ on port **443**.
- **WordPress + PHP-FPM**: Pre-configured WordPress instance using PHP-FPM (FastCGI Process Manager) for performance.
- **MariaDB**: Dedicated database service for WordPress.

#### Bonus microservices
- **Redis Cache**: Accelerates WordPress page loading via object caching.
- **FTP Server (vsftpd)**: Secure gateway allowing users to transfer files to the WordPress volume.
- **Adminer**: Single-file database management tool, proxied securely via NGINX.
- **Netdata**: Lightweight monitoring agent for real-time host and container performance statistics.
- **Static Site**: An elegant way to insert the  Webserver project of 42  in a container, served by NGINX.

---

## Technical Comparisons

### Main Design Choices & Comparisons

#### 1. Virtual Machines vs Docker
- **Virtual Machines**: Emulate a complete OS (including kernel). Heavy, slow to start, high resource usage.
- **Docker**: OS-level virtualization. Containers are lightweight, start in seconds, and share the host kernel while maintaining strong isolation.

#### 2. Secrets vs Environment Variables
- We used a `.env` file combined with Docker Secrets best practices for sensitive data (database passwords, etc.).
- **Environment Variables** are convenient for development but can be exposed more easily.
- **Docker Secrets** (or mounted secret files) are more secure for production as they are stored in memory (not on disk) and have tighter access control.

#### 3. Docker Network vs Host Network
- We used a custom **Docker bridge network** (`docker-compose.yml` with `networks`).
- This provides better **isolation** between containers and the host.
- `network: host` is forbidden in this project (as per subject rules) because it breaks isolation and port management.

The `host` network mode makes the container use the host's networking namespace directly, which reduces isolation. 
In this project, a dedicated `bridge` network is used to provide a private network where containers can communicate using 
their service names (internal DNS) while remaining isolated from the host's other processes.

#### 4. Docker Volumes vs Bind Mounts
- We used **named volumes** for persistent data (MariaDB data and WordPress files).
- **Advantages over Bind Mounts**:
    - Better portability (no dependency on host path structure)
    - Better management with Docker commands (`docker volume`)
    - Improved security and encapsulation
- Volumes are stored in `/home/login/data` on the host as required by the subject.

---

## Instructions

### Prerequisites
- A Linux-based Virtual Machine in my case I used Alpine).
- Docker and Docker Compose installed.
- Configure your `/etc/hosts` to point `dasalaza.42.fr` to `127.0.0.1`.

### Commands
Use the provided `Makefile` to manage the project:

```bash
# Set up directories, env configs, secrets, build images, and start the stack
make all

# Stop and pause all containers
make down

# Soft cleanup of containers and networks
make clean

# Hard cleanup: wipes containers, networks, secrets, and persistent host data
make fclean

# View live aggregate logs
make logs
```

---

## Resources

### References
- [Docker Official Documentation](https://docs.docker.com/)
- [Nginx TLS Configuration Guide](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [MariaDB Environment Variables](https://hub.docker.com/_/mariadb)
- [WordPress CLI Documentation](https://make.wordpress.org/cli/handbook/)
- [Architecture of KVM & QEMU](https://www.itstorage.net/index.php/sme/vmte-2/617-architecture-kvm-qemu-libvirt-ovs)
- [Understand QEMU/KVM hypervisor driver](https://libvirt.org/drvqemu.html)
- [The libvirt API concepts](https://libvirt.org/api.html)
- [Docker API concepts](https://docs.docker.com/reference/api/engine/version/v1.54/#section/Errors)

### AI Usage
AI was utilized in this project for the following tasks:
- **Optimization**: Assistance in writing efficient entrypoint scripts and optimizing Dockerfile layers.
- **Explanation**: Clarification of complex concepts like PID 1, signal forwarding, and the differences between TLS versions.
- **Structure**: Helping format the documentation files according to the 42 curriculum standards.
