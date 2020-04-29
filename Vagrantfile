# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  ################
  # General config
  ################

  config.vm.box = "ubuntu/bionic64"

  config.vm.provider "virtualbox" do |vb|
    # A bit more RAM
    vb.memory = 8192
    vb.cpus = 4

    # Shared storage for bitcoin source code
    config.vm.synced_folder "../bitcoin", "/bitcoin"
  end

  ################
  # Network config
  ################

  # No port forwarding
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # No private network
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Public bridged network
  config.vm.network "public_network"

  #####################
  # Provisioning script
  #####################

  config.vm.provision :shell, path: "bootstrap.sh", args: "-u vagrant"

end
