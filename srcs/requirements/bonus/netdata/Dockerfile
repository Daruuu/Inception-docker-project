FROM alpine:3.22

# 1. Instalar netdata y dependencias para plugins
RUN apk update && apk add --no-cache netdata bash

# El flag -p evita errores si la carpeta ya existe
RUN mkdir -p /var/cache/netdata /var/lib/netdata /usr/share/netdata/web && \
    chown -R netdata:netdata /var/cache/netdata /var/lib/netdata /usr/share/netdata/web

# 4. Puerto por defecto
EXPOSE 19999

# 5. Lanzar en primer plano (-D) escuchando en todas las interfaces
CMD ["netdata", "-D", "-i", "0.0.0.0"]

