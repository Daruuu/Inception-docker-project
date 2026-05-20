*This project has been created as part of the 42 curriculum by dasalaza.*
# Inception

## Description
This project aims to improve my knowledge of **system administration** using Docker.
The main goal of this project is to build a secure web infrastructure composed of three services: **Nginx** 
(as a reverse proxy with TLS), **WordPress** (with PHP-FPM), and **MariaDB** (database), all orchestrated through **Docker Compose**.

### Why Docker?
Docker was chosen because it allows us to create **lightweight**, **portable**, and **isolated** environments using 
container technology. Unlike traditional virtual machines, Docker containers share the host kernel, which provides:

- **Much better performance** (near-native speed).
- **Lower resource consumption** (CPU, RAM, and disk).
- **Faster startup and deployment.**
- **Great portability** between different Linux distributions, development, and production environments.

#### How Docker achieves isolation and resource control
Docker uses two fundamental Linux kernel technologies:

- **Namespaces**: These create isolated workspaces for each container. They make a container believe it is the 
**only application** running on the operating system. Namespaces isolate:
    - Processes (PID namespace)
    - Network (ports, IP addresses, routing)
    - File system (mount points)
    - Users and groups
    - Hostname, among others.

- **Cgroups (Control Groups)**: These are responsible for **limiting and monitoring** the resources each container 
can use (CPU, memory, disk I/O, network bandwidth, etc.). This prevents one container from consuming all the 
server’s resources and affecting the stability of other services.

Together, **namespaces + cgroups** give Docker an excellent balance between **security**, **performance**, and **efficiency**. 
This is what makes containers much lighter and faster than traditional virtual machines.

This project helped me deeply understand key containerization concepts, such as building Docker images, orchestrating 
multiple containers with **Docker Compose**, managing persistent data with volumes, and configuring networking between 
services. It also highlighted the importance of designing a solid and scalable infrastructure for any project, 
while teaching modern system administration best practices including security hardening, environment separation, 
and Infrastructure as Code.

---

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
1. **Security-First Base Images**: Built exclusively on top of the penultimate stable version of Alpine Linux.
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

### Bonus Microservices Architecture

To make the infrastructure more complete and realistic, I added **5 additional production-grade services** connected 
through a custom internal Docker network:

1. **Redis Cache**
    - **Purpose**: Speeds up WordPress by caching database queries in memory.
    - **Result**: Much faster page loading and reduced load on MariaDB.

2. **FTP Server (vsftpd)**
    - **Purpose**: Allows secure file transfer to the WordPress folder.
    - **Result**: Easy upload, backup, and management of website files.

3. **Adminer**
    - **Purpose**: Web interface to manage the MariaDB database.
    - **Result**: Secure access (protected behind Nginx) without exposing the database port publicly.

4. **Netdata**
    - **Purpose**: Real-time monitoring dashboard.
    - **Result**: Shows CPU, memory, disk, and network usage of all containers.

5. **Static Website**
    - **Purpose**: Containerized version of the previous 42 `Webserver project`.
    - **Result**: Served as a separate site under the `/static/` path.

All bonus services are fully integrated into the custom Docker bridge network, isolated, and proxied securely through Nginx.

---

## Technical Comparisons

### Main Design Choices & Comparisons

#### 1. Virtual Machines vs Docker
- **Virtual Machines**: Emulate a complete hardware layer and run a full guest Operating System (including its own kernel). This makes them heavy, resource-intensive, and slow to start.
- **Docker Containers**: Share the host system's kernel while isolating application processes in user space using Linux **namespaces** and **cgroups**. This provides near-native performance, extremely fast startup times, and minimal resource overhead while maintaining high security and isolation.

#### 2. Secrets vs Environment Variables
- **Environment Variables** (`.env`): Excellent for non-sensitive configurations (e.g., domain names, database names, ports) but highly insecure for passwords, as they can be easily leaked via `docker inspect`, process listings, or logs.
- **Docker Secrets**: Used for all sensitive data (database passwords, administrative credentials). Secrets are securely loaded at runtime and mounted as temporary virtual files (under `/run/secrets/`), ensuring that sensitive credentials are never baked into Docker images, exposed to child processes, or leaked into the environment.

#### 3. Docker Network vs Host Network
- **Host Network**: Shares the host's networking namespace directly, removing container-level network isolation. This is forbidden in this project because it poses security risks and causes port conflicts.
- **Docker Bridge Network**: An isolated, private internal network namespace created specifically for this stack (`inception_network`). Services can only communicate with each other using internal DNS resolution (service names), fully isolated from unauthorized host processes or external scans. NGINX acts as the *only* gateway to this network via port 443.

#### 4. Docker Volumes vs Bind Mounts
- **Bind Mounts**: Directly mount a specific folder from the host filesystem into a container, making the configuration highly dependent on the host's directory structure and permissions.
- **Docker Named Volumes**: Managed natively by the Docker engine, abstracting the underlying storage while providing optimal performance and backup capabilities.
- **Our Hybrid Design Choice**: To strictly satisfy both subject constraints—using **Docker Named Volumes** while ensuring they store data under a specific host directory (`/home/<login>/data`)—we implemented named volumes backed by a local bind mount driver (`type: none`, `o: bind`). This delivers the portable encapsulation of named volumes alongside complete control over the host storage path.

---

## Instructions

### Prerequisites
- A Linux-based Virtual Machine (in my case I used Alpine).
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
