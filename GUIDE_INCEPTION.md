# 🚀 Guía Ágil de Inception: De 0 a 100

Esta guía está diseñada para que completes el proyecto de forma eficiente, siguiendo un orden lógico que minimiza errores de depuración, sin saltarte los conceptos teóricos clave que te preguntarán en la evaluación.

---

## Fase 1: El Cimiento Teórico (2-3 horas)
*No piques código aún. Entiende esto para no perder horas después.*

1.  **Docker vs VM:** Entiende que Docker comparte el Kernel del Host. Una VM emula el hardware completo.
2.  **PID 1 y Señales:** Entiende por qué un contenedor muere si su proceso principal termina y por qué no usar "hacks" como `tail -f`.
3.  **Redes en Docker:** Cómo funciona el DNS interno de Docker (puedes hacer `ping wordpress` desde el contenedor de nginx).
4.  **Volúmenes:** Diferencia entre *Bind Mounts* (prohibidos) y *Named Volumes* (obligatorios).

---

## Fase 2: Configuración del Entorno (1 hora)

1.  **Estructura de Carpetas:** Crea la estructura oficial del subject (la que vimos en el PDF).
2.  **Archivo `.env`:** Define aquí tus variables (DB_NAME, DB_USER, DB_PASS, DOMAIN_NAME).
3.  **Hosts:** Edita `/etc/hosts` en tu VM para que `login.42.fr` apunte a `127.0.0.1`.

---

## Fase 3: Implementación Incremental (El Corazón)

### Paso A: MariaDB (La Base)
*¿Por qué primero?* Porque WordPress no arrancará sin una base de datos lista.
*   **Teoría:** Entiende cómo MariaDB guarda los datos en `/var/lib/mysql`.
*   **Acción:** 
    1. Crea el `Dockerfile` (basado en Debian/Alpine).
    2. Crea un script `.sh` que se ejecute al inicio para configurar la DB y el usuario (usando las variables del `.env`).
    3. Prueba el contenedor solo.

### Paso B: WordPress + PHP-FPM
*   **Teoría:** Entiende que PHP-FPM escucha en el puerto 9000. WordPress son archivos PHP que necesitan ser interpretados.
*   **Acción:**
    1. `Dockerfile`: Instala `php-fpm` y `mariadb-client`.
    2. Script de inicio: Usa `wp-cli` para descargar e instalar WordPress automáticamente.
    3. Configura `www.conf` de PHP-FPM para que escuche en el puerto 9000 en lugar de un socket.

### Paso C: NGINX (La Puerta de Entrada)
*   **Teoría:** TLS/SSL (Handshake, Certificados). NGINX actuará como servidor web y proxy para PHP.
*   **Acción:**
    1. Crea certificados auto-firmados con `openssl`.
    2. Configura el archivo `nginx.conf` para escuchar en el puerto 443 con TLS 1.2/1.3.
    3. Configura el `location ~ \.php$` para enviar las peticiones a `wordpress:9000`.

---

## Fase 4: Orquestación con Docker Compose

1.  Une todo en `srcs/docker-compose.yml`.
2.  Define las redes (bridge).
3.  Define los volúmenes y asegúrate de que apunten a `/home/login/data`.
4.  Configura las `restart: always`.

---

## Fase 5: Automatización (Makefile)

Crea un `Makefile` con las reglas:
*   `all`: Crea las carpetas de datos en el host y levanta todo (`docker-compose up -d --build`).
*   `down`: Detiene los contenedores.
*   `re`: Hace un `down` seguido de un `all`.
*   `clean`: Borra contenedores, redes y imágenes.
*   `fclean`: Borra todo, incluidos los volúmenes y las carpetas de datos del host.

---

## Fase 6: Documentación y Defensa

1.  **USER_DOC.md:** Instrucciones simples de cómo usarlo.
2.  **DEV_DOC.md:** Detalles técnicos para alguien que quiera tocar el código.
3.  **Simulacro de Defensa:**
    *   ¿Cómo compruebas que el volumen persiste? (Borra el contenedor, levántalo y mira si los posts de WP siguen ahí).
    *   ¿Cómo compruebas el TLS? (`curl -I -v --sslv3 https://login.42.fr` -> debe fallar).
    *   ¿Cómo entras a un contenedor? (`docker exec -it <nombre> sh`).

---

### 💡 Tips para agilizar:
*   **Usa `docker logs -f <nombre>`:** Es tu mejor amigo cuando algo no levanta.
*   **No instales NGINX en el contenedor de WordPress:** Es el error más común y está prohibido.
*   **WP-CLI:** Aprender a usarlo te ahorrará horas configurando WordPress manualmente en el navegador.
