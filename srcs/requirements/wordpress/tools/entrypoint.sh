#!/bin/sh

# Incrementar límite de memoria para PHP y WP-CLI
export PHP_OPTIONS="-d memory_limit=512M"

# 1. Leer secretos si existen (Docker Secrets)
if [ -f "/run/secrets/db_password" ]; then
    SQL_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f "/run/secrets/wp_admin_password" ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi

# Validar variables
if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ]; then
    echo "ERROR: Variables de base de datos no definidas."
    exit 1
fi
if [ -z "$WP_ADMIN_PASSWORD" ]; then
    echo "ERROR: WP_ADMIN_PASSWORD no está definida."
    exit 1
fi

# Esperar a que MariaDB esté lista
echo "Esperando a que MariaDB esté disponible en el host 'mariadb'..."
until mariadb-admin ping -h mariadb -u"${SQL_USER}" -p"${SQL_PASSWORD}" --silent; do
    echo "MariaDB no está lista todavía. Reintentando en 2 segundos..."
    sleep 2
done

echo "MariaDB está lista. Procediendo con la instalación de WordPress."

# Asegurar que el directorio existe y tiene los permisos correctos
mkdir -p /var/www/html/wordpress
chown -R nobody:nobody /var/www/html/wordpress

if [ ! -f "/var/www/html/wordpress/wp-config.php" ]; then
    echo "Instalando WordPress..."

    # Descargamos los archivos de WordPress
    # shellcheck disable=SC2164
    cd /var/www/html/wordpress
    until php -d memory_limit=512M /usr/local/bin/wp core download --allow-root; do
        echo "Error descargando WordPress. Reintentando..."
        sleep 5
    done

    # Creamos el archivo wp-config.php
    php -d memory_limit=512M /usr/local/bin/wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser=${SQL_USER} \
        --dbpass=${SQL_PASSWORD} \
        --dbhost=mariadb \
        --allow-root

    # Instalamos WordPress (creamos el sitio)
    php -d memory_limit=512M /usr/local/bin/wp core install \
        --url=${WP_URL} \
        --title=${WP_TITLE} \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    # Creamos un usuario adicional (requerido por el subject)
    php -d memory_limit=512M /usr/local/bin/wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author \
        --allow-root

    # +++++++++++++++++++++++ BONUS: Configuración de Redis Cache
    echo "Configurando Redis Cache..."
    php -d memory_limit=512M /usr/local/bin/wp plugin install redis-cache --activate --allow-root

     IMPORTANTE: Configurar Redis ANTES de habilitarlo
    php -d memory_limit=512M /usr/local/bin/wp config set WP_REDIS_HOST redis --allow-root
    php -d memory_limit=512M /usr/local/bin/wp config set WP_REDIS_PORT 6379 --raw --allow-root
    php -d memory_limit=512M /usr/local/bin/wp config set WP_CACHE true --raw --allow-root

    # Reintentar habilitar Redis (esperando a que el contenedor esté listo)
    echo "Habilitando Redis Object Cache..."
    until php -d memory_limit=512M /usr/local/bin/wp redis enable --allow-root; do
        echo "Redis no responde todavía. Reintentando en 2 segundos..."
        sleep 2
    done

    echo "WordPress instalado correctamente con Redis Cache."
else
    echo "WordPress ya está instalado."
fi

# Ajustar permisos finales por si acaso
chown -R nobody:nobody /var/www/html/wordpress

echo "Iniciando PHP-FPM..."
exec /usr/sbin/php-fpm83 -F