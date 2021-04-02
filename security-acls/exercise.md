# Exercise: Redis ACLs

## Connect to Environment

In a terminal run this command to get a shell prompt inside the running docker container:

```
docker-compose exec redis_acls redis-cli
```

## Update the default account

1. Using the `ACL SETUSER` command set the password for the default account to `Sec&789`.
1. Aftwards you should be able to run this command and get back an `OK` response: 
    ```
    AUTH default Sec&789
    ```
    If you get this error: `(error) WRONGPASS invalid username-password pair` you have set the password incorrectly.


## Use command category ACLs

1. View all categories of commands that can be used with ACLs:
    ```
    ACL CAT
    ```
1. View the specific commands of a given category:
    ```
    ACL CAT dangerous
    ```
1. Add a new user with a password and access to the `hash` category.
1. Authenticate using the new username and password using the `AUTH` comamnd.
1. Verify proper access was granted
    A `SET` command should return the following error but the `HSET` command should not.
    ```
    (error) NOPERM this user has no permissions to run the 'set' command or its subcommand
    ```
    Remember to make sure that a key ACL was also set: `~*` otherwise it won't work.

    
## Use key based ACL

1. Auth back to the default user
1. Set some keys:
    ```
    mset bucket:1 dirt bucket:2 turf pail:1 sand
    ```
1. Add a new user `bucket-reader` that is enabled with a password `redis123` with **read only* access to keys starting with `bucket:` 
1. Authenticate using the new username and password using the `AUTH` comamnd.
1. Verify proper access was granted:
    - can get bucket:1
    - can NOT get pail:1
    - can NOT set bucket:3 or any other key  
    Validation should look something like this:
    ```
    > auth bucket-reader redis123
    OK
    > get bucket:1
    "dirt"
    > get pail:1
    (error) NOPERM this user has no permissions to access one of the keys used as arguments
    > set bucket:3 water
    (error) NOPERM this user has no permissions to run the 'set' command or its subcommand
    ```


## ACL admin and other utilities

1. Auth back to the default user
1. Run `ACL HELP` to view available ACL commands
1. Verify you are the default user by running `ACL WHOAMI`
1. Run `ACL LIST` to view all current users and ACLs
1. Run `ACL LOG` to view auth events
1. Run `ACL DELUSER bucket-reader` then `ACL LIST` to verify the user was deleted

