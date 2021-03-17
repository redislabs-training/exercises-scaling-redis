FROM redis:latest

RUN apt update && apt-get install -y openssl wget

COPY gen-certs.sh /tmp/

RUN /tmp/gen-certs.sh /etc/certs

WORKDIR /

RUN mkdir /usr/local/etc/redis

RUN wget https://raw.githubusercontent.com/redis/redis/6.2/redis.conf -P /usr/local/etc/redis/

ENTRYPOINT ["tail", "-f", "/dev/null"]