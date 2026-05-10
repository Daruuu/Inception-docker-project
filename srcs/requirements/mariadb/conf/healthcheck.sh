#!/bin/sh

# Leer el secreto de la contraseña root
if [ -f /run/secrets/db_root_password ]; then
    ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
else
    # Fallback por si no hay secretos (aunque en este proyecto debería haberlos)
    ROOT_PASSWORD=$SQL_ROOT_PASSWORD
fi

# Verificar si MariaDB responde
mysqladmin ping -h localhost -u root --password="$ROOT_PASSWORD"
