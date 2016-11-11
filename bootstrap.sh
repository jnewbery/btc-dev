#!/usr/bin/env bash
set -Eeux
set -o posix
set -o pipefail

declare -r guest_log="/vagrant/guest_logs/vagrant_mmc_bootstrap.log"
declare -r bitcoin_data_dir="/home/vagrant/.bitcoin"

echo "$0 will append logs to $guest_log"
echo "Bootstrap starts at "`date`
bootstrap_start=`date +%s`

mkdir -p "$(dirname "$guest_log")"

declare -r exe_name="$0"
echo_log() {
    local log_target="$guest_log"
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $exe_name: $@" >> $log_target
}

echo_log "start"
echo_log "uname: $(uname -a)"
echo_log "current procs: $(ps -aux)"
echo_log "current df: $(df -h /)"

# add 2G swap to avoid around annoying ENOMEM problems (does not persist across reboot)
echo_log "create swap"
mkdir -p /var/cache/swap/
dd if=/dev/zero of=/var/cache/swap/swap0 bs=1M count=2048
chmod 0600 /var/cache/swap/swap0
mkswap /var/cache/swap/swap0
swapon /var/cache/swap/swap0

# baseline system prep
echo_log "base system update"
apt-get -y update
apt-get -y install vim

# add blockchain tools to path
sudo -u vagrant cp -r /vagrant/tools /home/vagrant
cat >>/home/vagrant/.bashrc <<EOL

# add blockchain tools to path
PATH=\$PATH:/home/vagrant/tools
EOL

# Git
apt-get -y install git

# Open SSL dev libraries
apt-get -y install libssl-dev

# Python 3.5, whynot?
# http://askubuntu.com/questions/682869/how-do-i-install-newer-python-versions-using-apt-get
# https://launchpad.net/~fkrull/+archive/ubuntu/deadsnakes/+index?batch=75&memo=75&start=75
add-apt-repository -y ppa:fkrull/deadsnakes
apt-get -y update
apt-get -y install python3.5

# Autoreconf
apt-get -y install dh-autoreconf

# Boostlib
apt-get -y install libboost-all-dev

# libevent
apt-get -y install libevent-dev

# libdb_cxx
apt-get -y install libdb++-dev

# pkg-config
apt-get -y install pkg-config

# GNU debugger
apt-get -y install gdb

# Python 3 zmq for running the python test suite
apt-get -y install python3-zmq

# Get and build Berkeley DB 4.8
# NOTE - we won't actually do this. Just build bitcoin without portable wallets.
# wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
# tar -xvf db-4.8.30.NC.tar.gz
# cd db-4.8.30.NC/build_unix
# ../dist/configure
# make install
# cd ~

# Get and build Bitcoin
echo_log "Getting and building bitcoin"
#git clone https://github.com/bitcoin/bitcoin 
sudo -u vagrant cp -R /bitcoin ~vagrant/bitcoin
sudo -u vagrant ~vagrant/tools/BTC_build -g

# Make bitcoin data directory
mkdir "$bitcoin_data_dir"
chown -R vagrant:vagrant "$bitcoin_data_dir"
sudo -u vagrant cp /vagrant/conf/bitcoin.conf "$bitcoin_data_dir"

# Get the python-bitcoinrpc library
echo_log "Getting python-bitcoinrpc"
apt-get -y install python-pip python-dev build-essential 
pip install --upgrade pip
pip install --upgrade virtualenv
pip install python-bitcoinrpc

echo_log "complete"
echo "Bootstrap ends at "`date`
bootstrap_end=`date +%s`
echo "Bootstrap execution time is "$((bootstrap_end-bootstrap_start))" seconds"
echo "$0 all done!"

