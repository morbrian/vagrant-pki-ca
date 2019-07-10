#!/bin/bash

CA_KEY=/etc/pki/CA/private/ca.key
CA_CRT=/etc/pki/CA/certs/ca.crt

if [ $# -eq 0 ]
  then
    echo "Must supply SERVER_NAME, and optionally 'clean' to overwrite old files"
    echo "syntax: servercert.sh hostname.fqdn.com [clean]"
    exit 1
fi

SERVER_NAME=$1
CLEAN=$2
ARCHIVE=/root/certgen
SERVER_CSR=/etc/pki/CA/csr/${SERVER_NAME}.csr
SERVER_KEY=/etc/pki/CA/private/${SERVER_NAME}.key
SERVER_CRT=/etc/pki/CA/certs/${SERVER_NAME}.crt
SERVER_TGZ=${ARCHIVE}/${SERVER_NAME}.tgz
SUBJECT="/OU=CONTRACTOR/OU=PKI/OU=DoD/ST=California/O=sandbox/C=US/CN=${SERVER_NAME}"

mkdir -p ${ARCHIVE}

if [ -f ${SERVER_CSR} ]; then
    echo "CSR already exists: ${SERVER_CSR}"
    if [ "${CLEAN}" == "clean" ]; then
        echo "removing ${SERVER_CSR}"
        rm ${SERVER_CSR}
    else
        exit 1
    fi
fi
if [ -f ${SERVER_KEY} ]; then
    echo "KEY already exists: ${SERVER_KEY}"
    if [ "${CLEAN}" == "clean" ]; then
        echo "removing ${SERVER_KEY}"
        rm ${SERVER_KEY}
    else
        exit 1
    fi
fi
if [ -f ${SERVER_CRT} ]; then
    echo "CRT already exists: ${SERVER_CRT}"
    if [ "${CLEAN}" == "clean" ]; then
        echo "removing ${SERVER_CRT}"
        rm ${SERVER_CRT}
    else
        exit 1
    fi
fi

echo "generate server private key"
openssl genrsa -out ${SERVER_KEY} 4096

echo "generate signing request for CA"
openssl req -sha256 -new -key ${SERVER_KEY} -out ${SERVER_CSR} -subj "${SUBJECT}"

echo "sign the request with CA"
openssl ca -batch -keyfile ${CA_KEY} -cert ${CA_CRT} -extensions usr_cert -notext -md sha256 -in ${SERVER_CSR} -out ${SERVER_CRT}

echo "Archive key and cert to ${SERVER_TGZ}"
tar --transform 's/.*\///g' -cvzf ${SERVER_TGZ} ${SERVER_KEY} ${SERVER_CRT} ${CA_CRT}
