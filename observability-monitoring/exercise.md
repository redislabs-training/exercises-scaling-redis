# Exercise: Monitoring in Redis Enterprise

## Setup
After the docker-compose -d command has successfully started up the Redis Enterprise docker container we will need to bootstrap Redis Enterprise.  This involves creating a single node cluster.  Note that in Redis Enterprise a cluster node equates to an instance resourece on which Redis Enterprise is installed and not just where a Redis server process is running.

There is a setup.sh script provided which will get things started so you can focus on the exercises.

Run from this directory:

```
./setup.sh
```

Once that completes you should be able to load Redis Enterprise admin UI in a browser.

https://localhost:8443/

Redis Enterprise creates self-signed certs in the beginning so a secure connection is always created.  Since they are not CA signed certificates you will need to allow your browser to accept them.

Depending on your browser and version you may have an 'advanced' option that allows to accept and continue/proceed.  Some Chrome browser versions will not have this option, but you can bypass this warning by just typing 'thisisunsafe' and it will automatically continue through to the site.

Once you bypass the browser warning you should see a login screen where you can use the following credentials to login:

username: admin@redis.com  
password: redis123

Once successfully logged in you should see the Redis Enterprise administration UI.


## Generate some load

The setup script created a database that we can use exposed on port 12000.  Generate some load into the database using another open source load generation utility for Redis called memtier_benchmark.  It is included with the Redis Enterprise install so we can simple run:

```
docker-compose exec redis_enterprise_monitoring memtier_benchmark -p 12000 -x 1000
```

That will just take all the defaults for most of the options except the `p` param to specify port which we need to set to 12000 because the database on Redis Enterprise was created to use that port and the `x` param to indicate how many times to run the default test.  This will allow us to be able to see some results in Redis Enterprise.

You can find more information about memtier_benchmarks options using the `--help` option.

## Cluster Dashboard

Now go back to your browser where you logged in and click the 'cluster' nav menu item. By default this will open the metrics tab.

You should be able to see the overal Cluster Ops/sec and on the right Node 1 Ops/sec.  These stats should be the same because in setup (dev/testing only) we have a single node cluster.

Scroll down to the other metrics and hover over 'Free RAM' this should provide a little more detail and give you the option to move this metic to one of the top spots.  If you click on the right side box the metric should move to the top right.

## Node Dashboard

Navigate to the nodes page by clicking the 'nodes' option in the nav menu.  This should just display our single node. If we had joined other nodes to the cluster you would see multiple nodes here.

Click on node 1 to view it's metrics.  Now click on the '5 Minutes' text in the time scale to change the sampling time.

You can view the node specific details by clicking on the 'configuration' tab. This will show the version of Redis Enterprise, Redis, IP address, OS and other details.

## Database Dashboard

Navigate to the databases page by clicking the 'databases' option in the nav menu.  Since a Redis Enterprise cluster can support multi-tenancy you can run multiple databases across the same set of resources.  This page will show a list of the database that have been created in this cluster.  The setup script created one database 'db-1' so click on that now.

You should be taken into the database metrics view immediately.  You can see the Ops/sec and the Latency.  Scroll down to view other metrics.

What is the used memory at?  What is the usage percentage?

How many connections are you getting from the memtier utility?

What are the total keys?  How about your hit ratio?

Notice at the top there is a rectangular blue switch box with 'Database' selected.  You can click on 'Shards' to view shard specific data.  

In our case there won't be much difference in the actual numbers because we are currently running a single shard, but this can be very useful to identify hot shards and get other insights into the database health.

## Prometheus Exporter

You can what data is available on the Prometheus exporter endpoint by calling it on port 8070:

```
docker-compose exec redis_enterprise_monitoring curl -k https://localhost:8070/metrics
```

## REST API

The Redis Enterprise REST API also has a way to pull stats directly.  You can try pulling stats for the databases:

```
docker-compose exec redis_enterprise_monitoring curl -k -u learn@redislabs.com:redis123 https://localhost:9443/v1/bdbs/stats
```

You can explore the following query params:

* `interval` – Optional time interval for for which we want stats: 1sec/10sec/5min/15min/1hour/12hour/1week
* `stime` – Optional start time from which we want the stats. Should comply with the ISO_8601 format
* `etime` –
Optional end time after which we don’t want the stats. Should comply with the ISO_8601 format

Add an interval query param to set the interval time to five minutes.

Stats can be pulled from different endpoints as well:

* `/v1/bdbs/stats` - databases
* `/v1/nodes/stats` - nodes stats
* `/v1/cluster/stats` - cluster

Try each of these endpoints.

Also, the id of a specific entity can be passed, for example if we wanted to just get the stats of our database with the id=1 and not the full array we could run:

```
docker-compose exec redis_enterprise_monitoring curl -k -u learn@redislabs.com:redis123 https://localhost:9443/v1/bdbs/stats/1
```

Now do the same thing for the nodes endpoint and just get the stats for node=1.

## Stop Load Generation

You can just use ctl-c in the terminal window where memtier_benchmark is running to to exit.