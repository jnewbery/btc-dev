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

# add 2G swap to avoid arround annoying ENOMEM problems (does not persist across reboot)
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

# Git
apt-get -y install git

# Open SSL dev libraries
apt-get -y install libssl-dev

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

# Get and build Bitcoin
echo_log "Install bitcoin from source"
git clone https://github.com/bitcoin/bitcoin
cd bitcoin
./autogen.sh && ./configure --with-incompatible-bdb && make && make install

# Make bitcoin data directory
mkdir "$bitcoin_data_dir"
chown -R vagrant:vagrant "$bitcoin_data_dir"
sudo -u vagrant cp /vagrant/conf/bitcoin.conf "$bitcoin_data_dir"

# add blockchain tools to path
#sudo -u vagrant mkdir -p /home/vagrant/tools
#sudo -u vagrant cp /vagrant/tools/* /home/vagrant/tools
#echo '' >> /home/vagrant/.bashrc
#echo '# add blockchain tools to path' >> /home/vagrant/.bashrc
#echo 'PATH=$PATH:/home/vagrant/tools' >> /home/vagrant/.bashrc

echo_log "complete"
echo "Bootstrap ends at "`date`
bootstrap_end=`date +%s`
echo "Bootstrap execution time is "$((bootstrap_end-bootstrap_start))" seconds"
echo "$0 all done!"