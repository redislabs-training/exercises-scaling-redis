# Exercise: High Availability in Redis Enterprise

## Getting started
After the docker-compose -d command has successfully started up the Redis Enterprise docker container we check to make sure that internally Redis Enterprise is ready to start taking requests.

Run from this directory:

```
./verify-readiness.sh
```

Once that completes with a successful message you should be able to proceed to:

https://localhost:18443/

Redis Enterprise creates self-signed certs in the beginning so a secure connection is always created.  Since they are not CA signed certificates you will need to allow your browser to accept them.

Depending on your browser and version you may have an 'advanced' option that allows to accept and continue/proceed.  Some Chrome browser versions will not have this option, but you can bypass this warning by just typing 'thisisunsafe' and it will automatically continue through to the site.

Once you bypass the browser warning you should see a the initial setup screen.


## Create cluster on node 1

You will see a large red 'Setup' button.  Click that to begin setting up the Redis Enterprise cluster.

The node configuration page will show some initial defaults including local file paths to use, IPs, etc.  You can take these defaults.  Please note the IP of this first node as you will need it in subsequent steps.

Make sure the 'Create new cluster' is selected and then enter a 'Cluster name' value: `cluster.local` and click next (leaving the other checkboxes empty).  NOTE: In this local setup using docker we will not be able to fully use the DNS capabilities of Redis Enterprise.

The next screen will prompt you for cluster authentication by asking you to enter a license key.  Just click next here and a trial license will automatically be used.

Now you will need to set admin credentials.  These will be used in subsequent steps.  Here is an example of something that will work:

**Email**: admin@redis.com
**Password**: redis123  

After credentials have been set you will be taken immediately to a screen to create a database.  We do not need to do that yet. 

## Join cluster on node 2

Now let's move to node 2 and join this node to the Redis Enterprise cluster. Enter this address in the browser address bar:  

https://localhost:28443  

This will again require you to bypass the self-signed certificate warning in the browser. Please refer to instructions above to bypass.

You will again be prompted with the large red setup button, click that to proceed.  On the node configuration page you will now select 'Join cluster' in the cluster configuration area.  Enter the IP of the first node (`172.22.0.11`) and the credentials you created, then click Next.

Normally after a cluster is created on a node or a node joins a cluster Redis Enterprise will update the self-signed certs with the cluster domain name configured.  In this exercise environment where we keep re-using localhost and don't have unique IPs that we can enter into the host browser it may cause issues.  You might need to reload your browser a few times which may lead to accepting the self-signed certs again and another login.

Once you get past all of this you will be taken to a screen to create a database. As you have noticed this is where Redis Enterprise will redirect you if no database exists yet.

Let's leave the browser at this place and open up a terminal.

## Join cluster on node 3 using rladmin

You could go through the same steps that we did for node 2 to join node 3 to the cluster, but let's take the opportunity to see that there are other options. Note: there are three ways to create a cluster... administration UI in the browser, `rladmin` CLI and the administration REST API.

The `rladmin` CLI utility is fairly easy to access in this dockerized exercise environment so let's use that. First connect to node 3 shell:

```
docker-compose exec re3 bash
```

This should land you on a prompt like this (with a diff container ID):

```
redislabs@cc13e2721cd9:/opt$ 
```

Now run `rladmin` to get the interactive mode of the utility.  At the `rladmin>` prompt you can enter ow enter the tab key twice to view a list of available commands.  Since this node is not currently set up there is really only one command `cluster` (besides exit or help).

Enter `cluster` followed by the tab key twice to view a list of available options....now add `join` to the command.  You can enter the tab key twice to view a list of available options:

```
rladmin> cluster join 
accept_servers        cnm_https_port        flash_enabled         nodes                 password              replace_node          
addr                  ephemeral_path        flash_path            override_rack_id      persistent_path       required_version      
ccs_persistent_path   external_addr         json_file             override_repair       rack_id               username   
```

We will not use all of these, but you might remember the management UI node configuration screen during setup and notice some similar fields.  Since our setup is simple and we can take most of the defaults let's just provide a minimal command to join this node to the cluster:

```
rladmin> cluster join nodes 172.22.0.11 username admin@redis.com password redis123
Joining cluster... ok
rladmin> 
```

You will need to replace the above username and password with the credentials that you created when you created the cluster.

With the cluster joined you should now have more command options available to you.  Enter the tab key twice to view a list of available commands which should include different cluster management commands that can be used to view cluster configurations or even update them.

View the cluster status by entering:

```
rladmin> status
```

You should have a display with different sections:

- `CLUSTER NODES`
- `DATABASES`
- `ENDPOINTS`
- `SHARDS`

Currently you should only have data in the `CLUSTER NODES` section since you have not added a database yet.  Speaking of... 


## Create database

Return to the browser window you left before.  The session has likely timed out which will require you to login again.  After a successful login you should now be presented with the prompt to create a new dataase. Select 'redis database,' 'Runs on ram' and 'Single Region' and click 'Next.'

You should now have a screen to enter the database details. Let's keep it simple to start with by entering a name and checking the 'Replication' box then click the 'Activate' button.  Redis Enterprise will create a single sharded database with replication using it's state machine to stand up necessary resources and connect them together.

That's it, you just created a database with high availability!

## Replication details

Return to the terminal and run `rladmin status` again and you should see additional sections containing data about your database.  Each database has an endpoint and shards associated with it.  If you look at the `SHARDS` section in detail you should see two shards one acting as a primary and the other a secondary replica.

What nodes are the shards on?


## Create another database

Go back to the browser administration UI and click on 'databases' in the nav menu.  You should see the database you created.  Redis Enterprise supports multi-tenancy: meaning you can create additional databases and will be allocated resources and managed independently.

Click on the '+' icon under your database name and create another database with replication (the trial license allows for four shards so you should have enough).

Now return to the terminal and run `rladmin> status` again.  You should now see two databases with unique IDs, two endpoints and four shards total.

Where were the second database shards placed?

The cluster manager will place nodes according to available resources and ensure that the primary and secondary replica shards are never on the same node.

This is a simple single primary shard with replica use-case but when we move on to scaling you will see how Redis Enterprise can maintain sharded databases across nodes with replication.
