# Nginx Proxy Server with Docker

This repository contains the Dockerfile and all other files necessary to create the container for the Nginx proxy server.

## Table of Contents

* [Running the Container] (#running-the-container)

## Building the Container

Build the container from source, optionally specifying branch build with a hashtag. Note that spork requires SSH authentication, so run from a computer with .ss/id_rsa file set up.

        sudo docker build -t nginx git@github.com/morbrian/vagrant-nginx.git

## Running the Container

The nginx server is configured to listen to port 8443, so in order to connect
over 443 the port mapping below should be added to the run command.

            -p 443:8443

The nginx server expects a list of certificates to exist in a volume and will
not start until the certificates are provided.

+ cert.crt
+ cert.key
+ trusted-ca-signers.pem
+ ha-proxy-cert.cer

The volume must be added at to the run time with a special character at the end to prevent SELinux from throwing a permission denied error when the container attempts to read the files.

            sudo docker run -d -p 443:8443 --name=nginx -v /docker/volumes:/etc/nginx/certs:z --restart always nginx
            
            sudo docker build -t nginx git@github.com/morbrian/vagrant-nginx.git
            sudo docker run -d -p 80:8080 --name=sample nginx

## Certificate Management

This sandbox VM includes a local Certificate Authority for managing self signed certificates used for development.

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


