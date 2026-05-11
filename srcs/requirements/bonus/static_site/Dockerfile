FROM alpine:3.22

RUN apk add --no-cache \
	g++ \
    make \
	libstdc++ \
	wget \
	unzip 

WORKDIR /app

RUN wget https://github.com/Anagamedina/webserv/archive/refs/heads/main.zip -O webserv.zip

RUN unzip webserv.zip && \
	rm webserv.zip && \
	mv webserv-main/* . && \
	rm -rf webserv-main

RUN grep -R "<sys/signal.h>" -n src include || true

RUN find src include -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) \
    -print0 | xargs -0 sed -i 's|<sys/signal.h>|<signal.h>|g'
RUN make
EXPOSE 8080

CMD ["./webserver", "config/default.conf"]
