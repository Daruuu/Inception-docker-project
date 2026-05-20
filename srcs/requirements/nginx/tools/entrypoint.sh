#!/bin/sh

# Create this dir of SSL if not exist
mkdir -p /etc/nginx/ssl

# Generate certificado SSL using the variable WP_URL
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "[INFO] Generating self-signed SSL certificate for $WP_URL..."

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=ES/ST=Barcelona/L=Barcelona/O=42/CN=$WP_URL"

    echo "[INFO] SSL certificate successfully generated."
fi

# Update server_name in Nginx configuration
echo "[INFO] Setting server_name to $WP_URL in Nginx config..."
sed -i "s/server_name _;/server_name $WP_URL;/g" /etc/nginx/http.d/default.conf

# Start Nginx in foreground mode
echo "[INFO] Starting Nginx..."
exec nginx -g "daemon off;"