# Exercise: Enabling TLS in Redis

## Understaing the context

## Starting up Redis with TLS
redis-server --tls-port 6379 --port 0 --tls-cert-file /etc/certs/server.crt --tls-key-file /etc/certs/server.key --tls-ca-cert-file /etc/certs/ca.crt

## Connecting redis-cli using TLS
redis-cli --tls --cert /etc/certs/client.crt --key /etc/certs/client.key --cacert /etc/certs/ca.crt