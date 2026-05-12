FROM alpine:3.22.0

RUN apk update && apk add --no-cache vsftpd

COPY requirements/bonus/ftp/config/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY requirements/bonus/ftp/tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["sh", "/usr/local/bin/setup.sh"]
