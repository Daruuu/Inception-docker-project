FROM alpine:3.17

RUN apk update && apk add --no-cache mariadb mariadb-client

# Prepara carpetas y copia tus archivos
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld
COPY requirements/mariadb/conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY requirements/mariadb/tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["sh", "/usr/local/bin/setup.sh"]


