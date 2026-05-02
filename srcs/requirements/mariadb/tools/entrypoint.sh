#!/bin/sh

# Verifica si la base de datos ya está inicializada.
# Si el directorio /var/lib/mysql/mysql existe, asumimos que ya está configurada.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "=> Instalando la base de datos de MariaDB..."
    
    # Inicializa el directorio de datos de MariaDB
    # Esto crea las tablas del sistema necesarias para MariaDB
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null

    echo "=> Iniciando MariaDB temporalmente en background..."
    # Iniciamos mysqld en background usando mysqld_safe (el envoltorio recomendado)
    # y esperamos a que el socket esté disponible para poder ejecutar comandos.
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    # Esperamos hasta que MariaDB esté listo para recibir conexiones
    while ! mariadb-admin ping --silent; do
        sleep 1
    done

    echo "=> Leyendo secretos de Docker..."
    # Leemos las contraseñas desde los archivos inyectados por Docker Secrets
    # Usamos tr -d '\n' para asegurarnos de que no haya saltos de línea extraños al leer el archivo
    _DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password | tr -d '\n')
    _DB_PASSWORD=$(cat /run/secrets/db_password | tr -d '\n')
    # Nota: DB_NAME y DB_USER normalmente vienen del .env, no son secretos críticos
    
    echo "=> Configurando usuarios y bases de datos..."

    # Creamos un archivo temporal con los comandos SQL
    cat << EOF > /tmp/init.sql
-- Borramos cualquier usuario root sin contraseña que venga por defecto
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- Cambiamos la contraseña del usuario root local
ALTER USER 'root'@'localhost' IDENTIFIED BY '${_DB_ROOT_PASSWORD}';

-- Creamos la base de datos para WordPress si no existe
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

-- Creamos el usuario de WordPress
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${_DB_PASSWORD}';
-- Le damos todos los permisos al usuario de WordPress sobre su base de datos
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

-- Aplicamos los cambios
FLUSH PRIVILEGES;
EOF

    # Ejecutamos el archivo SQL usando el cliente mariadb
    mariadb -u root < /tmp/init.sql
    
    # Borramos el archivo temporal por seguridad
    rm -f /tmp/init.sql

    echo "=> Apagando MariaDB temporal..."
    # Apagamos el servidor temporal de forma segura
    mariadb-admin -u root -p"${_DB_ROOT_PASSWORD}" shutdown
    
    # Esperamos a que el proceso en background termine completamente
    wait
    
    echo "=> Configuración inicial completada."
else
    echo "=> La base de datos ya está configurada."
fi

echo "=> Iniciando MariaDB (PID 1)..."
# Ejecutamos el demonio mysqld en primer plano (foreground). 
# 'exec' reemplaza el proceso actual (el script bash) por mysqld, 
# convirtiéndolo en el PID 1 del contenedor. Esto permite que Docker capture las señales (como docker stop).
exec mysqld --user=mysql --console
