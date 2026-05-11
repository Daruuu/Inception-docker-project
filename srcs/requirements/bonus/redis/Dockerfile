FROM alpine:3.22

RUN apk update && apk add --no-cache redis

# Configuración básica: permitir conexiones externas y establecer políticas de memoria
RUN sed -i "s|bind 127.0.0.1|bind 0.0.0.0|g" /etc/redis.conf && \
    echo "maxmemory 256mb" >> /etc/redis.conf && \
    echo "maxmemory-policy allkeys-lru"  && \
    echo "protected-mode no" >> /etc/redis.conf

EXPOSE 6379

# Ejecutar redis-server con el archivo de configuración modificado
CMD ["redis-server", "/etc/redis.conf"]
