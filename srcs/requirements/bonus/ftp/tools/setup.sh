#!/bin/sh

# 1. Leer secretos si existen (Docker Secrets)
if [ -f "/run/secrets/ftp_password" ]; then
    FTP_PASS=$(cat /run/secrets/ftp_password)
elif [ -f "/run/secrets/wp_user_password" ]; then
    FTP_PASS=$(cat /run/secrets/wp_user_password)
fi

# El nombre de usuario lo cogemos de la variable de entorno (definida en .env)
if [ -z "$FTP_USER" ]; then
    FTP_USER="default-user"
fi

# 2. Crear el usuario si no existe
if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "Creando usuario FTP: $FTP_USER"
    adduser -D "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    
    # Asegurar que el directorio de WordPress existe y tiene los permisos correctos
    mkdir -p /var/www/html/wordpress
    chown -R "$FTP_USER:$FTP_USER" /var/www/html/wordpress
fi

# 3. Asegurar que el archivo de log exista para vsftpd
touch /var/log/vsftpd.log

echo "FTP Server starting for user: $FTP_USER"

# 4. Lanzar vsftpd en primer plano
exec vsftpd /etc/vsftpd/vsftpd.conf
