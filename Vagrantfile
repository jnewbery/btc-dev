# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Virtualbox specific config

  config.vm.provider "virtualbox" do |vb, override|
    override.vm.box = "ubuntu/trusty64"
    # A bit more RAM
    vb.memory = "1024"

    # Network config

    # No port forwarding
    # config.vm.network "forwarded_port", guest: 80, host: 8080

    # No private network
    # config.vm.network "private_network", ip: "192.168.33.10"

    # Public bridged network
    override.vm.network "public_network"

    # provisioning script
    override.vm.provision :shell, path: "bootstrap.sh", args: "-u vagrant"
  end

  # AWS specific config

  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"

    # Ubuntu - trusy64
    aws.ami = "ami-c8580bdf"

    # username must be ubuntu for this ami
    override.ssh.username = "ubuntu"

    # provisioning script
    override.vm.provision :shell, path: "bootstrap.sh", args: "-u ubuntu"
  end

end

# Load AWS private config
aws_private = File.expand_path('../Vagrantfile-private-aws', __FILE__)
load aws_private if File.exists?(aws_private)
