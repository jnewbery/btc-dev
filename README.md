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
- Run `vagrant up` to start the machine.

#### Running remotely on AWS

- Make sure that the [vagrant-aws plugin](https://github.com/mitchellh/vagrant-aws) is installed.
- Super secret AWS config is stored in `Vagrantfile-private-aws`. Update that file with your AWS config.
- Use the aws provisioning script to provision the machine: `aws/provision`

##### A note on Vagrant-private-aws

A sample `Vagrant-private-aws` is checked into the repository. If you change `Vagrant-private-aws` and run `git status`, it'll show up as modified and unstaged. To suppress that (and stop yourself from accidentally checking in your supersecret AWS config into a public repository), you should run the following command to make git assume that the file is always unmodified:

`git update-index --assume-unchanged Vagrantfile-private-aws`

### What to do next

- log into your VM using `vagrant ssh`
- fix bugs, write code, open pull request
