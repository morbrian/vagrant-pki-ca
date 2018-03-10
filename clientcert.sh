#!/bin/bash

#
# NOTE:
# The openssl configuration at /etc/pki/tls/openssl.cnf must be modified to include the emailAddress
# In the section [ usr_cert ] uncomment to include this: 
#   subjectAltName=email:move
# Possibly also (for signing) include this in section v3_ca (didn't test)
#   subjectAltName=email:copy
#

#CN=TARGARYEN.DAENERYS.MIDDLE.1234567890,OU=CONTRACTOR,OU=PKI,OU=DoD,O=U.S. Government,C=US
#/CN=TARGARYEN.DAENERYS.MIDDLE.1234567890/OU=CONTRACTOR/OU=PKI/OU=DoD/O=U.S. Government/C=US/

SUBJECT_CN=TARGARYEN.DAENERYS.MIDDLE.1234567890
SUBJECT_EMAIL=daenerys.targeryen@dragonstone.got

openssl genrsa -out /etc/pki/CA/private/${SUBJECT_CN}.key 4096

openssl req \
        -sha256 \
        -new \
        -key /etc/pki/CA/private/${SUBJECT_CN}.key \
        -out /etc/pki/CA/csr/${SUBJECT_CN}.csr \
        -subj "/CN=${SUBJECT_CN}/emailAddress=${SUBJECT_EMAIL}/OU=CONTRACTOR/OU=PKI/OU=DoD/ST=California/O=sandbox/C=US/" \
        -extensions usr_cert

# sign the client request
openssl ca \
        -batch \
        -keyfile /etc/pki/CA/private/ca.sandbox.com.key \
        -cert /etc/pki/CA/certs/ca.sandbox.com.crt \
        -in /etc/pki/CA/csr/${SUBJECT_CN}.csr \
        -out /etc/pki/CA/certs/${SUBJECT_CN}.crt \
        -notext \
        -md sha256 \
        -extensions usr_cert
