FROM alpine:3.22.0

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-mbstring \
    php83-openssl \
    php83-xml \
    php83-zip \
    php83-phar \
    php83-tokenizer \
    php83-ctype \
    wget \
    fcgi \
    unzip \
    mariadb-client

RUN ln -sf /usr/bin/php83 /usr/bin/php

# Install wp-cli (this fundamental tool configure WP in cmd)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Update configuration of PHP-FPM , listen in port 9000
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php83/php-fpm.d/www.conf

WORKDIR /var/www/html/wordpress

COPY requirements/wordpress/tools/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY requirements/wordpress/tools/healthcheck.sh /usr/local/bin/healthcheck.sh

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh

EXPOSE 9000

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]