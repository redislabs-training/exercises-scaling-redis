# Exercise: Scaling in Redis Enterprise

## Getting started
After the docker-compose -d command has successfully started up the Redis Enterprise docker container we need to setup a Redis Enterprise cluster. Since you have already gone through the individual steps to do this in the High Availability exercise there is a setup script provided.

Run from this directory:

```
./setup.sh
```

If you wish to go through the setup manually you can go back to the High Availability exercise and go through the steps there or open the setup.sh and view the commands that are being run.

Once that completes with a successful message you should be able to open a browser:

https://localhost:18443/

Redis Enterprise creates self-signed certs in the beginning so a secure connection is always created.  Since they are not CA signed certificates you will need to allow your browser to accept them.

Depending on your browser and version you may have an 'advanced' option that allows to accept and continue/proceed.  Some Chrome browser versions will not have this option, but you can bypass this warning by just typing 'thisisunsafe' and it will automatically continue through to the site.

Once you bypass the browser warning you should see a the login screen. Use these credentials

username: admin@redis.com
password: redis123


## Create database

After a successful login you should be presented with the prompt to create a new dataase. Select 'redis database,' 'Runs on ram' and 'Single Region' and click 'Next.'

You should now have a screen to enter the database details. Let's keep it simple to start with by entering a name and hen click the 'Activate' button.  Redis Enterprise will create a single sharded database.

Open a terminal to and connect to the `rladmin` utility and view the cluster status to see the details.

```
docker-compose exec re1 bash
```

During the Redis Enterprise exercise on High Availability you used `rladmin` in interactive mode, but you can also pass commands and options in directly as args.

```
:/opt$ rladmin status shards
```

This will show the `SHARDS` section of the status.  You should just have a single shard for the database.  Now get the databases section so you can find the endpoint, particularly the port.

```
:/opt$ rladmin status databases
```

Look in the `ENDPOINT` column and copy the port that was generated for this database.  Since we dont' have the full features of Redis Enterprise with DNS, etc. in this dockerized environment we will just call the database using it's exertnal port.  The request will still go through the proxy.

## Create Traffic

Now let's use that port in `memtier_benchmark` a Redis benchmarking utility.  Just replace the port from the example with your own. You should see the benchmark client begin to send traffic to your database:

```
 memtier_benchmark -p 19100 -x 1000
[RUN #1] Preparing benchmark client...
[RUN #1] Launching threads now...
```

## Scale Database

Go back to your browser and reload the database page.  You may need to login again if the session has expired.  View the 'metrics' tab and verify traffic is being sent to your database.

Go back to the configuration view and click 'Edit' at the bottom to edit the database.  Enable the checkbox for 'Database clustering' and enter 4 shards and click 'Update' at the bottom. The Redis Enterprise cluster manager will update the database using it's state machine to add the additional Redis processes, re-shard, re-balance and re-bind the endpoint.  

Open the 'metrics' view again.

Open the 'metrics' view again, your database should still be taking client requests.

NOTE: With the limited resources of this dockerized environment there may be performance bumps.  This exercise is not intended to show an increase in performance just the ease of managing the scaling process.

## Stop traffic

You can use `ctl-c` in the terminal to stop the traffic.

Exit out of the container shell by entering `exit` back to your own system's terminal.


