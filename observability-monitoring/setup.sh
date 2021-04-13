#!/usr/bin/env bash

printf '\nCheck for Redis Enterprise to be ready: '
until $(docker exec -it observability-monitoring_redis_enterprise_monitoring_1 sh -c "curl --output /dev/null --silent --head --fail -k https://localhost:9443/v1/bootstrap"); do
    printf '.'
    sleep 3
done
printf ' success\n'

printf '\nBootstrap: '
docker exec -it observability-monitoring_redis_enterprise_monitoring_1 sh -c "/opt/redislabs/bin/rladmin cluster create name cluster.local username admin@redis.com password redis123"


printf '\nCreate DB\n'
docker exec -it observability-monitoring_redis_enterprise_monitoring_1 sh -c "curl --output /dev/null --silent -X POST -H 'cache-control: no-cache' -H 'Content-type: application/json' -u admin@redis.com -d '{ \"name\": \"db-1\", \"memory_size\": 52428800, \"sharding\": false, \"shards_count\": 1, \"type\": \"redis\", \"proxy_policy\": \"single\", \"shards_placement\": \"dense\", \"port\": 12000}' -k https://localhost:9443/v1/bdbs"

printf '\nGood to go!\n'