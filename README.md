# btc-dev

Virtual machine configuration for development environment for [bitcoin](https://github.com/bitcoin/bitcoin).

This vagrant configuration can be used to provision a virtual machine locally (using Virtualbox) or remotely on AWS.

### What it's doing

Provisioning a bitcoin development environment by grabbing all the dependencies, then building bitcoin from source.

### Running the VM

#### Requirements for both local and remote VMs

- Make sure that [vagrant](http://www.vagrantup.com/downloads) is installed.
- git clone this repository and git clone https://github.com/bitcoin/bitcoin (or a fork) into the same directory. The bitcoin directory will sync into the VM.

#### Running locally using Virtualbox

- Make sure that [Virtualbox](https://www.virtualbox.org/wiki/Downloads) is installed.
- `vagrant up`

#### Running remotely on AWS

- Super secret AWS config is stored in `Vagrantfile-private-aws`. Update that file with your AWS config.
- `vagrant up --provisioner=aws`

### What to do next

- log into your VM using `vagrant ssh`
- run bitcoind, run bitcoin tests, etc
- fix bugs, write code, open pull request

### Contributing

This was thrown together very quickly. Any comments, issues, PRs gratefully accepted.
