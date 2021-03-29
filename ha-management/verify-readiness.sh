#!/usr/bin/env bash

printf '\nCheck for Redis Enterprise to be ready: '

until $(docker exec -it re1 sh -c "curl --output /dev/null --silent --head --fail -k https://localhost:9443/v1/bootstrap"); do
    printf '.'
    sleep 3
done
printf ' Ready to continue!\n'