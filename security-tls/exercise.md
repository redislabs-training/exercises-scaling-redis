# Exercise: Enabling TLS in Redis

## Connect to Environment

In a terminal run this command to get a shell prompt inside the running docker container:

```
docker-compose exec redis_tls bash
```

## Container Context

The docker-compose will startup a docker container based on the standard Redis docker image, but it will create some self-signed certs in order to try out the TLS support.

If you `ls` the `/etc/certs/` directory you can see there are client and server certs.

If you wish to understand how these self-signed certs were created you can view the shell script used either in this repo `gen-certs.sh` or inside the container `/tmp/gen-certs.sh` where it was copied.  In fact this was adapted from a similiar script in the Redis repo under utilities that is used for testing purposes.

Using a container like this is just used for a quick lightweight learning environment to help you understand how to enable and work with the TLS settings. It is not intended to demonstrate how to deploy Redis.

## Starting up Redis with TLS flags

One way you can enable TLS support is by adding the TLS flags to the redis-server startup.  You can enable the TLS port and disable the regular TCP port, point to the certificate, key and CA cert.

```
redis-server --tls-port 6379 --port 0 --tls-cert-file /etc/certs/server.crt --tls-key-file /etc/certs/server.key --tls-ca-cert-file /etc/certs/ca.crt
```

If you ctl-c to exit the running process the Redis server will also stop.

## Starting up Redis with TLS configuration

The docker container has also had the default redis.conf file copied to: `/usr/local/etc/redis/redis.conf` but in the previous command we did not utilize it.

Let's try to enable the same TLS settings that we did above in this config and then start Redis with TLS support that way.

```
redis-server /usr/local/etc/redis/redis.conf
```

Now let's verify that we can connect using TLS from a client.

## Connecting redis-cli using TLS

Open another terminal window or tab and run this command to get a shell prompt inside that same docker container:

```
docker-compose exec redis_tls bash
```

We can use `redis-cli` to connect to our TLS enabled Redis server.

```
redis-cli --tls --cert /etc/certs/client.crt --key /etc/certs/client.key --cacert /etc/certs/ca.crt
```

If you are able to run the `INFO` or other commands you know that your client certificates have been accepted and TLS is being used for the connection.  If you are returned an error when trying to run a command you may need to:

- verify you have entered all the flags correctly
- go back to the first terminal window and check the errors
- fix any misconfigurations in the redis.conf and restart the server
- retest after making changes until you can run commands successfully
