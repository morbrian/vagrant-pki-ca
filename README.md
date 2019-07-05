# Simple local CA for development use

This repository provides a simple OpenSSL CA and helper scripts to help with local development.

## Certificate Management

This sandbox VM includes a local Certificate Authority for managing self signed certificates used for development.

## How to Produce Server Cert With Script

How to create server cert (output wil be under `/root/certgen` folder on VM

`sudo bash /vagrant/servercert.sh proxy.example.com`

How to create client cert (produces two certs one with email, one without, both under `/root/certgen` folder on VM)

`sudo bash /vagrant/usercert.sh ROMANOV.NATASHA.U`

## Base Commands Similar to Scripts (if needed)

Generate host1 private key

            openssl genrsa -out /etc/pki/CA/private/host1.develop.com.key 4096
            openssl req -sha256 -new -key /etc/pki/CA/private/host1.develop.com.key -out /etc/pki/CA/csr/host1.develop.com.csr -subj "/C=US/ST=California/L=San Diego/O=sandbox/CN=host1.develop.com"

Sign the host1 request

            openssl ca -batch -keyfile /etc/pki/CA/private/ca.sandbox.com.key -cert /etc/pki/CA/certs/ca.sandbox.com.crt -extensions usr_cert -notext -md sha256 -in /etc/pki/CA/csr/host1.develop.com.csr -out /etc/pki/CA/certs/host1.develop.com.crt


## Vagrant Sandbox

The Vagrantfile may be useful for local testing in development.

Building a proxy sandbox VM:

        vagrant up

Connecting to sandbox VM:

        vagrant ssh

Building docker containers in sandbox vm:

        sudo docker build -t nginx_img_1 /vagrant
        sudo docker run --name nginx_cont_1 -p 443:8443 -v /docker/volumes:/etc/nginx/certs:z -i -t nginx_img_1

Viewing certificates for a specific server configuration:

        openssl s_client -servername host1.develop.com -connect host1.develop.com:443 -showcerts

## Export/Import Container

In order to deploy a locally built container to a remote server you need to save the image as a tar and copy it to the server.

        sudo docker save -o <filename.tar> <image-name>
        scp <filename.tar> username@remoteserver:

Then after logging into the remote server you wilsll load the tar into the local docker registry and tag it with the appropriate version

        sudo docker load -i <filename.tar>
        sudo docker tag <image-name>:latest <image-name>:<version>


