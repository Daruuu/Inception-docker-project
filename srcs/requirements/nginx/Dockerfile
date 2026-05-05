FROM alpine:3.21.0

RUN apk update && apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=ES/ST=Barcelona/L=Barcelona/O=42/CN=anamedin.42.fr"

COPY requirements/nginx/conf/nginx.conf /etc/nginx/http.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

