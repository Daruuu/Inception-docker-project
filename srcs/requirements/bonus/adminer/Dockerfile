FROM alpine:3.22.0

# Instalamos PHP y las extensiones necesarias para conectar con MariaDB
RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-session \
    php82-curl \
    wget

# Descargamos el archivo único de Adminer
RUN mkdir -p /var/www/html
RUN wget "https://www.adminer.org/latest.php" -O /var/www/html/adminer.php

# Configuramos PHP-FPM para que escuche en el puerto 9000
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php82/php-fpm.d/www.conf

EXPOSE 9000

# Iniciamos PHP-FPM
CMD ["php-fpm82", "-F"]

