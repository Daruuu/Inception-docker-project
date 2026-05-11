FROM alpine:3.22.0

RUN apk update && apk add --no-cache nginx openssl

# Copiamos la configuración de Nginx (corregida la ruta de tools/ a tools/)
COPY requirements/nginx/tools/nginx.conf /etc/nginx/http.d/default.conf
# Copiamos y preparamos el script de entrada
COPY requirements/nginx/tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
