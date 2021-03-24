# Exercise - Get Metrics

## Connect to Environment

In a terminal run this command to get a shell prompt inside the running docker container:

```
docker-compose exec redis_stats bash
```

## Generate load

A simple way to to generate some load is to open another terminal and run:

```
docker-compose exec redis_stats redis-benchmark 
```

## Info

Since most of the stats data comes from the `INFO` command you should first run this to view what there.


```
# redis-cli INFO
```

Try piping this output to a file.


## Memory usage

Since we generally recommend setting the `maxmemory` size, it is possible to calculate the percentage of memory in use and alert based on result of the maxmemory configuration value and the used_memory stat.

First set the `maxmemory`.

```
# redis-cli config set maxmemory 100000
```

Then you can pull the two data points to see how that could be used to calculate memory usage.

```
# redis-cli INFO |grep used_memory:
```

```
# redis-cli config get maxmemory
```

## Client data

You can pull the clients section of the `INFO` command:

```
# redis-cli info clients
```

or maybe a particular metric you would want to track:

```
# redis-cli info client | grep connected_clients
```

## Stats section

Use redis-cli to list the full 'stats' section.

## Hit ratio

A cache hit/miss ratio could be generated using two data points in the stats section.

```
# redis-cli INFO stats |grep keyspace
```

## Evicted keys

Eviction occurs when redis has reached its maximum memory and maxmemory-policy in redis.conf is set to something other than volatile-lru.

```
# redis-cli INFO stats | grep evicted_keys
```

## Expired keys

It is a good idea to keep an eye on the expirations to make sure redis is performing as expected.

```
# redis-cli INFO stats | grep expired_keys
```

## Keyspace

The following data could be used for graphing the size of the keyspace as a quick drop or spike in the number of keys is a good indicator of issues.

```
# redis-cli INFO keyspace
```

## Workload (connections received, commands processed)

The following stats are a good indicator of workload on the Redis server.

```
# redis-cli INFO stats |egrep "^total_"
```
