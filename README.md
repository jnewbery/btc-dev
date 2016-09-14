# btc-dev

Virtual machine configuration for development environment for [bitcoin](https://github.com/bitcoin/bitcoin).

### How to run

- Install [vagrant](http://www.vagrantup.com/downloads)
- Make sure you have a virtual machine provider. [Virtualbox](https://www.virtualbox.org/wiki/Downloads) will do.
- git clone bitcoin into the directory containing the btc-dev directory. Vagrant is setup to sync the bitcoin directory to /bitcoin in the VM.
- `vagrant up`

### What it's doing

Grabbing all the dependencies, then building bitcoin from source.

### What to do next

- log into your VM using `vagrant ssh`
- go into the lightning directory and run the tests `cd lightning && make check`
- fix bugs, write code, open pull request

### Contributing

This was thrown together very quickly. Any comments, issues, PRs gratefully accepted.