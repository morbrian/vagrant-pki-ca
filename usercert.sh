#!/bin/bash

#
# NOTE:
# The openssl configuration at /etc/pki/tls/openssl.cnf must be modified to include the emailAddress
# In the section [ usr_cert ] uncomment to include this: 
#   subjectAltName=email:move
# Possibly also (for signing) include this in section v3_ca (didn't test)
#   subjectAltName=email:copy
#
# WARNING: the local openssl CA database does not support duplicate common names.
#

CA_KEY=/etc/pki/CA/private/ca.key
CA_CRT=/etc/pki/CA/certs/ca.crt

if [ $# -eq 0 ]
  then
    echo "Must supply COMMON_NAME (leave off 10-digit id, we generate random), and optionally 'clean' to overwrite old files"
    echo "syntax: usercert.sh LAST.FIRST.MIDDLE [clean]"
    exit 1
fi

EDIPI=""
while [ ${#EDIPI} -lt 10 ]; do EDIPI=${EDIPI}${RANDOM}; done
EDIPI=${EDIPI:0:10}

USER_NAME=$1
SUBJECT_CN=${USER_NAME}.${EDIPI}
SUBJECT_EMAIL=$(echo "${USER_NAME}" | tr '[:upper:]' '[:lower:]')@example.fqdn
CLEAN=$2
ARCHIVE=/root/certgen
USER_CSR=/etc/pki/CA/csr/${USER_NAME}.csr
USER_EMAIL_CSR=/etc/pki/CA/csr/${USER_NAME}.email.csr
USER_KEY=/etc/pki/CA/private/${USER_NAME}.key
USER_EMAIL_KEY=/etc/pki/CA/private/${USER_NAME}.email.key
USER_CRT=/etc/pki/CA/certs/${USER_NAME}.crt
USER_EMAIL_CRT=/etc/pki/CA/certs/${USER_NAME}.email.crt
USER_TGZ=${ARCHIVE}/${USER_NAME}.tgz
SUBJECT_DN="/CN=${SUBJECT_CN}/OU=CONTRACTOR/OU=PKI/OU=DoD/ST=California/O=sandbox/C=US/"
SUBJECT_DN_WITH_EMAIL="/CN=EMAIL.${SUBJECT_CN}/emailAddress=${SUBJECT_EMAIL}/OU=CONTRACTOR/OU=PKI/OU=DoD/ST=California/O=sandbox/C=US/"

mkdir -p ${ARCHIVE}

if [ -f ${USER_CSR} ]; then
    echo "CSR already exists: ${USER_CSR}"
    if [ "${CLEAN}" == "clean" ]; then
        echo "removing ${USER_CSR}"
        rm ${USER_CSR}
    else
        exit 1
    fi
fi
if [ -f ${USER_KEY} ]; then
    echo "KEY already exists: ${USER_KEY}"
    if [ "${CLEAN}" == "clean" ]; then
        echo "removing ${USER_KEY}"
        rm ${USER_KEY}
    else
        exit 1
    fi
fi
if [ -f ${USER_CRT} ]; then
    echo "CRT already exists: ${USER_CRT}"
    if [ "${CLEAN}" == "clean" ]; then
        echo "removing ${USER_CRT}"
        rm ${USER_CRT}
    else
        exit 1
    fi
fi

echo "generate server private key"
openssl genrsa -out ${USER_KEY} 4096
openssl genrsa -out ${USER_EMAIL_KEY} 4096

echo "generate signing request for CA"
openssl req -sha256 -new -key ${USER_KEY} -out ${USER_CSR} -subj "${SUBJECT_DN}"
openssl req -sha256 -new -key ${USER_EMAIL_KEY} -out ${USER_EMAIL_CSR} -subj "${SUBJECT_DN_WITH_EMAIL}" -extensions usr_cert

echo "sign the request with CA"
openssl ca -batch -keyfile ${CA_KEY} -cert ${CA_CRT} -extensions usr_cert -notext -md sha256 -in ${USER_CSR} -out ${USER_CRT}
openssl ca -batch -keyfile ${CA_KEY} -cert ${CA_CRT} -extensions usr_cert -notext -md sha256 -in ${USER_EMAIL_CSR} -out ${USER_EMAIL_CRT} -extensions usr_cert

echo "Archive key and cert to ${USER_TGZ}"
tar --transform 's/.*\///g' -cvzf ${USER_TGZ} ${USER_KEY} ${USER_CRT} ${USER_EMAIL_KEY} ${USER_EMAIL_CRT}



