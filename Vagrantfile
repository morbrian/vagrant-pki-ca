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
  config.vm.network "private_network", ip: "192.168.33.11"

  config.vm.provision "shell", inline: <<-SHELL
    # useful for debugging
    yum -y install net-tools

    # get atomic command line
    yum -y install atomic

    yum -y install docker git
    systemctl start docker.service

    # initialize ca database    
    touch /etc/pki/CA/index.txt
    echo 1000 > /etc/pki/CA/serial

    # optional for local signing requests (because this is development)
    mkdir -p /etc/pki/CA/csr

    # gen ca private key
    openssl genrsa -out /etc/pki/CA/private/ca.sandbox.com.key 4096
    chmod 400 /etc/pki/CA/private/ca.sandbox.com.key

    # configure openssl
    sed -i 's/# keyUsage/keyUsage/' /etc/pki/tls/openssl.cnf

    # request ca public cert
    openssl req -new -x509 -days 365 -key /etc/pki/CA/private/ca.sandbox.com.key -sha256 -extensions v3_ca -out /etc/pki/CA/certs/ca.sandbox.com.crt -subj "/C=US/ST=California/L=San Diego/O=sandbox/CN=ca.sandbox.com"
    chmod 444 /etc/pki/CA/certs/ca.sandbox.com.crt

    #
    # default
    #

    # generate defaul private key
    openssl genrsa -out /etc/pki/CA/private/_.key 4096
    openssl req -sha256 -new -key /etc/pki/CA/private/_.key -out /etc/pki/CA/csr/_.csr -subj "/C=US/ST=California/L=San Diego/O=sandbox/CN=default.develop.com"

    # sign the default request
    openssl ca -batch -keyfile /etc/pki/CA/private/ca.sandbox.com.key -cert /etc/pki/CA/certs/ca.sandbox.com.crt -extensions usr_cert -notext -md sha256 -in /etc/pki/CA/csr/_.csr -out /etc/pki/CA/certs/_.crt

    #
    # HOST1
    #

    # generate host1 private key
    openssl genrsa -out /etc/pki/CA/private/host1.develop.com.key 4096
    openssl req -sha256 -new -key /etc/pki/CA/private/host1.develop.com.key -out /etc/pki/CA/csr/host1.develop.com.csr -subj "/C=US/ST=California/L=San Diego/O=sandbox/CN=host1.develop.com"

    # sign the host1 request
    openssl ca -batch -keyfile /etc/pki/CA/private/ca.sandbox.com.key -cert /etc/pki/CA/certs/ca.sandbox.com.crt -extensions usr_cert -notext -md sha256 -in /etc/pki/CA/csr/host1.develop.com.csr -out /etc/pki/CA/certs/host1.develop.com.crt

    #
    # HOST2
    #

    # generate host2 private key
    openssl genrsa -out /etc/pki/CA/private/host2.develop.com.key 4096
    openssl req -sha256 -new -key /etc/pki/CA/private/host2.develop.com.key -out /etc/pki/CA/csr/host2.develop.com.csr -subj "/C=US/ST=California/L=San Diego/O=sandbox/CN=host2.develop.com"

    # sign the host2 request
    openssl ca -batch -keyfile /etc/pki/CA/private/ca.sandbox.com.key -cert /etc/pki/CA/certs/ca.sandbox.com.crt -extensions usr_cert -notext -md sha256 -in /etc/pki/CA/csr/host2.develop.com.csr -out /etc/pki/CA/certs/host2.develop.com.crt

    #
    # HOST3
    #

    # generate host2 private key
    openssl genrsa -out /etc/pki/CA/private/host3.develop.com.key 4096
    openssl req -sha256 -new -key /etc/pki/CA/private/host3.develop.com.key -out /etc/pki/CA/csr/host3.develop.com.csr -subj "/C=US/ST=California/L=San Diego/O=sandbox/CN=host3.develop.com"

    # sign the host3 request
    openssl ca -batch -keyfile /etc/pki/CA/private/ca.sandbox.com.key -cert /etc/pki/CA/certs/ca.sandbox.com.crt -extensions usr_cert -notext -md sha256 -in /etc/pki/CA/csr/host3.develop.com.csr -out /etc/pki/CA/certs/host3.develop.com.crt

    # configure iptables
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p icmp -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
    iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
    iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited  
    iptables-save

    ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
    ip6tables -A INPUT -i lo -j ACCEPT
    ip6tables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
    ip6tables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
    ip6tables -A INPUT -d fe80::/64 -p udp -m udp --dport 546 -m state --state NEW -j ACCEPT
    ip6tables -A INPUT -j REJECT --reject-with icmp6-adm-prohibited
    ip6tables -A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
    ip6tables-save

    #
    # provide host certs to nginx volume
    #
    mkdir -p /docker/volumes
    cp /etc/pki/CA/private/*.key /docker/volumes
    cp /etc/pki/CA/certs/*.crt /docker/volumes
    cp /vagrant/trusted-ca-signers.pem /docker/volumes
    cp /vagrant/ha-proxy-cert.cer /docker/volumes

    # these can be run manually in vm terminal as root
    # docker build -t nginx_img_1 /vagrant
    # docker run --name nginx_cont_1 -p 443:8443 -v /docker/volumes:/etc/nginx/certs:z -i -t nginx_img_1

  SHELL
end
