#!/bin/bash

# Generate some test certificates which are used by the regression test suite:
#
#   ${folder}/tls/ca.{crt,key}          Self signed CA certificate.
#   ${folder}/tls/redis.{crt,key}       A certificate with no key usage/policy restrictions.
#   ${folder}/tls/client.{crt,key}      A certificate restricted for SSL client usage.
#   ${folder}/tls/server.{crt,key}      A certificate restricted fro SSL server usage.
#  ${folder}/tls/redis.dh              DH Params file.

generate_cert() {
    local name=$1
    local cn="$2"
    local opts="$3"
    local folder="$4"

    local keyfile=${folder}/${name}.key
    local certfile=${folder}/${name}.crt

    [ -f $keyfile ] || openssl genrsa -out $keyfile 2048
    openssl req \
        -new -sha256 \
        -subj "/O=Redis Learn/CN=$cn" \
        -key $keyfile | \
        openssl x509 \
            -req -sha256 \
            -CA ${folder}/ca.crt \
            -CAkey ${folder}/ca.key \
            -CAserial ${folder}/ca.txt \
            -CAcreateserial \
            -days 365 \
            $opts \
            -out $certfile
}

certs_folder=$1

mkdir -p ${certs_folder}

[ -f ${certs_folder}/ca.key ] || openssl genrsa -out ${certs_folder}/ca.key 4096
openssl req \
    -x509 -new -nodes -sha256 \
    -key ${certs_folder}/ca.key \
    -days 3650 \
    -subj '/O=Redis Test/CN=Certificate Authority' \
    -out ${certs_folder}/ca.crt

cat > ${certs_folder}/openssl.cnf <<_END_
[ server_cert ]
keyUsage = digitalSignature, keyEncipherment
nsCertType = server

[ client_cert ]
keyUsage = digitalSignature, keyEncipherment
nsCertType = client
_END_

generate_cert server "Server-only" "-extfile ${certs_folder}/openssl.cnf -extensions server_cert" $certs_folder
generate_cert client "Client-only" "-extfile ${certs_folder}/openssl.cnf -extensions client_cert" $certs_folder
