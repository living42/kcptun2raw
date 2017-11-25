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
  config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # socks5
  config.vm.network "forwarded_port",
    guest: 1080,
    host: 1089,
    host_ip: "127.0.0.1"

  # http proxy
  config.vm.network "forwarded_port",
    guest: 8080,
    host: 8089,
    host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.139.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network",
    use_dhcp_assigned_default_route: true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
  
    # Customize the amount of memory on the VM:
    vb.memory = "256"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    if [ ! -f /vagrant/config/udp2raw.conf ]
    then
       echo "--raw-mode faketcp -r 127.0.0.1:3336 --key foobarx" \
         > /vagrant/config/udp2raw.conf
    fi
  SHELL

  config.vm.provision "shell", inline: <<-SHELL
    set -ex

    apt-get update
    apt-get install -y supervisor privoxy software-properties-common
    add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
    apt-get update
    apt-get install shadowsocks-libev -y

    export KCPTUN_VERSION=20171113
    
    if [ ! -f "/root/kcptun-linux-amd64-${KCPTUN_VERSION}.tar.gz" ]
    then

        wget -O /root/kcptun-linux-amd64-${KCPTUN_VERSION}.tar.gz \
	    https://github.com/xtaci/kcptun/releases/download/v20171113/kcptun-linux-amd64-${KCPTUN_VERSION}.tar.gz
        mkdir /tmp/kcptun || true
        tar xzf /root/kcptun-linux-amd64-${KCPTUN_VERSION}.tar.gz -C /tmp/kcptun
        install /tmp/kcptun/client_linux_amd64 /usr/local/bin/kcptun
        rm -rf /tmp/kcptun
    fi

    export UDP2RAW_VERSION=20171111.0

    if [ ! -f "/root/udp2raw_binaries-${UDP2RAW_VERSION}.tar.gz" ]
    then
        wget -O /root/udp2raw_binaries-${UDP2RAW_VERSION}.tar.gz https://github.com/wangyu-/udp2raw-tunnel/releases/download/${UDP2RAW_VERSION}/udp2raw_binaries.tar.gz
        mkdir /tmp/udp2raw || true
        tar xzf /root/udp2raw_binaries-${UDP2RAW_VERSION}.tar.gz -C /tmp/udp2raw
        install /tmp/udp2raw/udp2raw_amd64_hw_aes /usr/local/bin/udp2raw
        rm -rf /tmp/udp2raw
    fi

    cp /vagrant/provision/programs.ini /etc/supervisor/conf.d/programs.conf

    service supervisor restart

  SHELL
end
