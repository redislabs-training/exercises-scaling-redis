#!/usr/bin/env bash

printf '\nBootstrap endpoint: '

until $(docker exec -it re1 sh -c "curl --output /dev/null --silent --head --fail -k https://localhost:9443/v1/bootstrap"); do
    printf '.'
    sleep 3
done
printf ' ready!\n'

printf '\nnode 1: '
docker exec -it re1 rladmin cluster create name cluster.local username admin@redis.com password redis123

printf '\nnode 2: '
docker exec -it re2 rladmin cluster join nodes 172.22.0.11 username admin@redis.com password redis123

printf '\nnode 3: '
docker exec -it re3 rladmin cluster join nodes 172.22.0.11 username admin@redis.com password redis123

printf '\nCluster setup complete!\n'