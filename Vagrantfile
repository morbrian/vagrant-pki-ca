# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "centos/7"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  #config.vm.network "private_network", ip: "192.168.33.11"

  config.vm.provision "shell", inline: <<-SHELL
    # initialize ca database    
    touch /etc/pki/CA/index.txt
    echo 1000 > /etc/pki/CA/serial

    # optional for local signing requests (because this is development)
    mkdir -p /etc/pki/CA/csr

    # gen ca private key
    openssl genrsa -out /etc/pki/CA/private/ca.key 4096
    chmod 400 /etc/pki/CA/private/ca.key

    # configure openssl
    sed -i 's/# keyUsage/keyUsage/' /etc/pki/tls/openssl.cnf

    # request ca public cert
    openssl req -new -x509 -days 365 -key /etc/pki/CA/private/ca.key -sha256 -extensions v3_ca -out /etc/pki/CA/certs/ca.crt -subj "/C=US/ST=California/L=San Diego/O=sandbox/CN=bcm-devel-ca"
    chmod 444 /etc/pki/CA/certs/ca.crt

    #
    # SAMPLE HOST1
    #

    # generate host1 private key
    openssl genrsa -out /etc/pki/CA/private/host1.develop.com.key 4096
    openssl req -sha256 -new -key /etc/pki/CA/private/host1.develop.com.key -out /etc/pki/CA/csr/host1.develop.com.csr -subj "/C=US/ST=California/L=San Diego/O=sandbox/CN=host1.develop.com"

    # sign the host1 request
    openssl ca -batch -keyfile /etc/pki/CA/private/ca.key -cert /etc/pki/CA/certs/ca.crt -extensions usr_cert -notext -md sha256 -in /etc/pki/CA/csr/host1.develop.com.csr -out /etc/pki/CA/certs/host1.develop.com.crt

  SHELL
end
