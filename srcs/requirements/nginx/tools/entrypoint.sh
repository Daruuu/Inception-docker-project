#!/bin/sh

# Create this dir of SSL if not exist
mkdir -p /etc/nginx/ssl

# Generamos el certificado SSL usando la variable WP_URL
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "Generando certificado SSL para $WP_URL..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=ES/ST=Barcelona/L=Barcelona/O=42/CN=$WP_URL"
fi

# Reemplazamos el nombre de dominio en la configuración de Nginx
echo "Configurando server_name como $WP_URL..."
# Buscamos la línea que contiene server_name: '_' y la reemplazamos
sed -i "s/server_name _;/server_name $WP_URL;/g" /etc/nginx/http.d/default.conf

# Ejecutamos Nginx en primer plano
echo "Init Nginx ..."
exec nginx -g "daemon off;"
