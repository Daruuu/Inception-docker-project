#!/bin/sh

# Creamos el directorio de SSL si no existe (por si acaso)
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
# Buscamos la línea que contiene server_name (que no esté comentada) y la reemplazamos
sed -i "s/server_name dasalaza.42.fr;/server_name $WP_URL;/g" /etc/nginx/http.d/default.conf

# Ejecutamos Nginx en primer plano
echo "Iniciando Nginx..."
exec nginx -g "daemon off;"
