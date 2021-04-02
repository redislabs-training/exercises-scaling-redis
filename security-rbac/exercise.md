# Exercise: RBAC in Redis Enterprise


## Setup
After the docker-compose -d command has successfully started up the Redis Enterprise docker container we will need to bootstrap Redis Enterprise.  This involved creating a single node cluster.  Note that in Redis Enterprise a cluster node equates to an instance resourece on which Redis Enterprise is installed and not just where a Redis server process is running.

There is a setup.sh script provided which will get things started so you can focus on the RBAC exercises.

Run from this directory:

```
./setup.sh
```

Once that completes you should be able to load Redis Enterprise admin UI in a browser.

https://localhost:8443/

Redis Enterprise creates self-signed certs at installation time so that a secure connection is always created. Since these certificates are not CA signed certificates, you will need to allow your browser to accept them.

In the Firefox browser this consists of just clicking through the Advanced button and finding the button to accept and continue. If you are using a Chrome browser, you can bypass this warning by typing 'thisisunsafe', and it will automatically continue through to the site.

Once you bypass the browser warning, you should see a login screen where you can use the following credentials to log in:

username: admin@redis.com   
password: redis123

Once successfully logged in, you should see the Redis Enterprise admin console and be taken to create a database immediately.

Leave all the defaults and click 'Next', which will take you to a screen where you can name the database, keep the existing defaults and click 'Activate' to create the database.

Now you should be ready for the RBAC exercises.

## Connect to the database

Redis Enterprise supports multi-tenancy (a single cluster can host separately managed databases) so a unique port and endpoint are created per database.

1. Find the database in the 'databases' menu and click on it
2. View the 'Endpoint' ... grab the port value in particular
3. Connect to redis-cli in the docker container on that port by running:

```
docker-compose exec redis_enterprise_rbac redis-cli -p <port-from-endpoint>
```

If you are successfully connected; you should be able to run the `INFO` command.

## Update Default User

1. Find the database in the databases menu and click the Edit button for the database
2. Add a password for the default user
3. Verify using the redis-cli from the first step and after connecting use the AUTH command with the new password
4. Disconnect from the database

## Create a simple command ACL and update it

1. Navigate to the 'access control' menu
2. View the default roles and redis acls
3. Add a new Redis ACL where you restrict commands to GEO by removing all commands and adding the geo category for all keys
4. Create a new role that has no control-plane access
5. Grant this role access to the database you created (or all databases) and add the new Redis ACL you just created
6. Now go to the users menu and create at least one new user with this role
7. Verify your changes were correct:
   1. redis-cli into the db as we did before
   2. auth *new-user* *new-user-pwd*
   3. run a GEO command (https://redis.io/commands#geo) `GEOADD Sicily 13.361389 38.115556 "Palermo" 15.087269 37.502669 "Catania"`
   4. run a string command `set fa la` and you should get a NOPERM error
8. Now go back to the admin UI and find the 'redis acls' menu again.  Append the ACL you just created with '+@string' and Update it.
9. Go back to the redis-cli prompt and re-run the string command 'set fa la' and it should succeed
8. Disconnect from your database

## Create a key restrictive ACL

1. Navigate back to 'redis acls' menu inside of 'access control' tab
2. Add a new Redis ACL that allows for access to all non-dangerous commands and keys starting with 'public:'
3. Apply this ACL to your database or all databases
4. Now navigate to 'roles' and add a new role that utilizes the ACL you just created
5. Now add this role to a new user
6. Verify your changes were correct:
   1. redis-cli into the db as we did before
   2. auth *new-user* *new-user-pwd*
   3. create new key/s prefixed with 'public:' like 'public:example' without a NOPERM error
   4. create new key/s not prefixed with 'public:' and get a NOPERM error
7. You can expirement with updating the key restriction with additional key matches or command inclusion/exclusions and then verifying them via redis-cli
8. Disconnect from your database

## Create new user with control plane access

1. In the Redis Enterprise admin UI navigate to the users are again under the access control menu
2. Use the plus button to create a new user
3. Fill in all the values with some fake/test values (you will need to remember the email and password) except for Role choose 'DB Viewer'
4. Now in a nother browser or in an 'incognito' type browser tab open https://localhost:8443 and login with this new user you just created
5. You should be presented with the databases view only. If you select the database you created notice that you can view the metrics page.  If you click on configuration the edit capability is disabled.
6. If you select the access control nav menu you only have the ability to change your own password.
