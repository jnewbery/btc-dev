# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # General config

  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: "bootstrap.sh"

  # virtualbox specific config

  config.vm.provider "virtualbox" do |vb|
    # A bit more RAM to avoid bitcoind memory problems
    vb.memory = "1024"

    # Shared storage for bitcoin source code
    config.vm.synced_folder "../bitcoin", "/bitcoin"
  end

  # Network config

  # No port forwarding
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # No private network
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Public bridged network
  config.vm.network "public_network"

end
