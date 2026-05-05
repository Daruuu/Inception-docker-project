# Use the penultim version of stable Alpine
FROM alpine:3.21.0

# Actualizamos el sistema e instalamos MariaDB y el cliente
RUN apk update && \
    apk upgrade && \
    apk add --no-cache mariadb mariadb-client

# MariaDB en Alpine necesita que se creen ciertos directorios para los sockets y los pids
# También nos aseguramos de que el usuario 'mysql' sea el dueño
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# Copiamos nuestro archivo de configuración
COPY requirements/mariadb/conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copiamos nuestro script de inicio
COPY requirements/mariadb/tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Le damos permisos de ejecución al script
RUN chmod +x /usr/local/bin/entrypoint.sh

# Exponemos el puerto estándar de MySQL/MariaDB
EXPOSE 3306

# Definimos el script como el punto de entrada
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
