#!/bin/sh

# 1. Leer secretos si existen (Docker Secrets)
if [ -f "/run/secrets/ftp_password" ]; then
    FTP_PASS=$(cat /run/secrets/ftp_password)
elif [ -f "/run/secrets/wp_user_password" ]; then
    FTP_PASS=$(cat /run/secrets/wp_user_password)
fi

# El nombre de usuario lo cogemos de la variable de entorno (definida en .env)
if [ -z "$FTP_USER" ]; then
    echo "WARNING: 'FTP_USER' not set, using 'default-user'."
    FTP_USER="default-user"
fi

# 2. Create user if not exist
if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "Creating user FTP: $FTP_USER"
    adduser -D "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd

    # Check if the directory of WordPress exist and have correct permissions
    mkdir -p /var/www/html/wordpress
    chown -R "$FTP_USER:$FTP_USER" /var/www/html/wordpress
fi

# 3. Check the log file exist in vsftpd config
touch /var/log/vsftpd.log

echo "FTP Server starting for user: $FTP_USER"

# 4. Lanzar vsftpd en primer plano
exec vsftpd /etc/vsftpd/vsftpd.conf
