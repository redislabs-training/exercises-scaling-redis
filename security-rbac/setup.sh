#!/usr/bin/env bash

printf '\nCheck for Redis Enterprise to be ready: '
until $(docker exec -it security-rbac_redis_enterprise_rbac_1 sh -c "curl --output /dev/null --silent --head --fail -k https://localhost:9443/v1/bootstrap"); do
    printf '.'
    sleep 3
done
printf ' success\n'

printf '\nBootstrap: '
docker exec -it security-rbac_redis_enterprise_rbac_1 sh -c "/opt/redislabs/bin/rladmin cluster create name cluster.local username learn@redislabs.com password redis123"


#printf '\nCreate DB\n'
#docker exec -it security-rbac_redis_enterprise_rbac_1 sh -c "curl --output /dev/null --silent -X POST -H 'cache-control: no-cache' -H 'Content-type: application/json' -u learn@redislabs.com:redis123 -d '{ \"name\": \"db-1\", \"memory_size\": 52428800, \"sharding\": false, \"shards_count\": 1, \"type\": \"redis\", \"proxy_policy\": \"single\", \"shards_placement\": \"dense\", \"port\": 12000}' -k https://localhost:9443/v1/bdbs"

printf '\nGood to go!\n'