# Inception

*This project has been created as part of the 42 curriculum by dasalaza.*

## Description
This project aims to broaden my knowledge of system administration by using Docker. I have virtualized several Docker images, creating them in a personal virtual machine. The goal is to set up a small infrastructure composed of different services (Nginx, WordPress, and MariaDB) running in dedicated containers, all orchestrated with Docker Compose.

### Key Features
- **Nginx**: The only entry point to the infrastructure, configured with TLSv1.2/v1.3 on port 443.
- **WordPress + PHP-FPM**: Pre-configured WordPress instance using PHP-FPM for performance.
- **MariaDB**: Dedicated database service for WordPress.
- **Persistence**: Using Docker named volumes stored at `/home/daruuu/data`.
- **Security**: Environment variables and Docker secrets are used to handle credentials, ensuring no passwords are hardcoded in the images.

---

## Technical Comparisons

### Virtual Machines vs Docker
Virtual Machines virtualize the hardware, including a full guest operating system. Docker containers, however, share the host's kernel and only isolate the application's processes. This makes Docker much more lightweight, portable, and faster to start compared to traditional VMs.

### Secrets vs Environment Variables
Environment variables are useful for general configuration but can be exposed in logs or process listings. Docker Secrets provide a more secure mechanism for sensitive data (like database passwords), as they are encrypted during transit and at rest, and are only accessible to the services that explicitly need them.

### Docker Network vs Host Network
The `host` network mode makes the container use the host's networking namespace directly, which reduces isolation. In this project, a dedicated `bridge` network is used to provide a private network where containers can communicate using their service names (internal DNS) while remaining isolated from the host's other processes.

### Docker Volumes vs Bind Mounts
Bind mounts depend on the specific directory structure of the host machine. Docker Named Volumes are managed entirely by Docker, making them more portable, easier to back up, and better performing for persistent data in production-like environments.

---

## Instructions

### Prerequisites
- A Linux-based Virtual Machine.
- Docker and Docker Compose installed.
- Configure your `/etc/hosts` to point `daruuu.42.fr` to `127.0.0.1`.

### Commands
Use the provided `Makefile` to manage the project:

```bash
# Build and start all services
make all

# Stop services
make down

# Full cleanup (containers, images, networks, and volumes)
make fclean

# View logs
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
