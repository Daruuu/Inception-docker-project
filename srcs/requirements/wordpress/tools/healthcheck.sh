#!/bin/sh

# Intentamos conectar al puerto 9000 de PHP-FPM
# Si fcgi está instalado, es la mejor forma. Si no, verificamos el puerto.
if command -v cgi-fcgi; then
    SCRIPT_NAME=/ping \
    SCRIPT_FILENAME=/ping \
    REQUEST_METHOD=GET \
    cgi-fcgi -bind -connect 127.0.0.1:9000
else
    # Fallback simple: comprobar si el puerto está abierto
    netstat -an | grep 9000 | grep LISTEN
fi
