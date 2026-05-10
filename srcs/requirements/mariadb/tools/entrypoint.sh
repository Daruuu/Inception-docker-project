#!/bin/sh

chown -R mysql:mysql /var/lib/mysql

# 1. Leer secretos si existen (Docker Secrets)
if [ -f "/run/secrets/db_password" ]; then
    SQL_PASSWORD=$(cat /run/secrets/db_password | tr -d '\n' | tr -d ' ')
fi

if [ -f "/run/secrets/db_root_password" ]; then
    SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password | tr -d '\n' | tr -d ' ')
fi

# Validar variables críticas
if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ]; then
    echo "ERROR: SQL_DATABASE, SQL_USER o SQL_PASSWORD no están definidos."
    exit 1
fi

# 2. Instala las tablas básicas si no existen
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando base de datos MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # 3. Crea el archivo temporal SQL para la configuración inicial
    cat << EOF > /tmp/init.sql
USE mysql;
FLUSH PRIVILEGES;

-- Configuramos root para acceso local y remoto (Adminer)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Configuramos la base de datos y el usuario de la App
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';

FLUSH PRIVILEGES;
EOF

    # 4. Ejecuta la configuración (bootstrap)
    mysqld --user=mysql --bootstrap < /tmp/init.sql
    rm -f /tmp/init.sql
    echo "Base de datos inicializada correctamente."
else
    echo "La base de datos ya existe. Saltando inicialización."
fi

# 5. Iniciamos MariaDB de forma normal (PID 1)
echo "Iniciando MariaDB como PID 1..."
exec mysqld --user=mysql --console