# dev

Vagrant virtual machine configuration for development environment.

This vagrant configuration can be used to provision a virtual machine locally (using Virtualbox) or remotely on AWS.

### What it's doing

Provisioning a development environment.

### Running the VM

#### Requirements for both local and remote VMs

- Make sure that [vagrant](http://www.vagrantup.com/downloads) is installed.

#### Running locally using Virtualbox

- Make sure that [Virtualbox](https://www.virtualbox.org/wiki/Downloads) is installed.
- `vagrant up`

#### Running remotely on AWS

- Make sure that the [vagrant-aws plugin](https://github.com/mitchellh/vagrant-aws) is installed.
- Super secret AWS config is stored in `Vagrantfile-private-aws`. Update that file with your AWS config.
- `vagrant up --provisioner=aws`

### What to do next

- log into your VM using `vagrant ssh`
- fix bugs, write code, open pull request
