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

# add 4G swap
echo_log "create swap"
dd if=/dev/zero of=/swapfile bs=1G count=4
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile   none    swap    sw    0   0' >> /etc/fstab

# baseline system prep
echo_log "base system update"
# add-apt-repository -y ppa:pi-rho/dev
apt-get -y update

# Get stuff:
#
# - ack
# - ccache
# - gdp
# - pip

apt-get -y install ack-grep ccache gdb python3-pip xdg-utils

# Get Python stuff:
#
# - ipython
apt-get -y install python-is-python3
pip3 install --upgrade pip
# hash -r pip3
pip3 install ipython

# Remind user to update dotfiles
cat >>/home/vagrant/.bashrc <<EOL

echo "Don't forget to update your dotfiles!"
EOL

# Bitcoin specific
##################

# Get stuff:
#
# - autoreconf
# - Boostlib
# - Clang
# - libdb_cxx
# - libevent
# - pkg-config
# - Python 3 zmq for running the python test suite
# - qt dependencies
# - zmq dependency
apt-get -y install dh-autoreconf libboost-all-dev libevent-dev pkg-config python3-zmq
apt-get -y install clang
apt-get -y install software-properties-common
apt-get -y install libdb-dev libdb++-dev
apt-get -y install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
apt-get -y install libzmq3-dev

# add blockchain tools to path
sudo -Hu vagrant cp -r /vagrant/tools /home/vagrant/
cat >>/home/vagrant/.bashrc <<EOL

# add blockchain tools to path
PATH=\$PATH:/home/vagrant/tools
EOL

# helpful alises
cat >>/home/vagrant/.bashrc <<'EOL'

# Handy bitcoin aliases
alias bd='bitcoind' #starts bitcoin
alias bcli='bitcoin-cli'
alias bb='BTC_build' #builds bitcoin
alias bs="(pgrep bitcoind > /dev/null && bcli stop) || bd" # stop/start bitcoind
alias bst='BTC_status'
alias tl='combine_logs.py -c | less -R'
EOL

# Get the python-bitcoinrpc library
echo_log "Getting python-bitcoinrpc"
apt-get -y install python-dev
pip3 install python-bitcoinrpc

# Make bitcoin data directory
mkdir "$bitcoin_data_dir"
chown -R vagrant:vagrant "$bitcoin_data_dir"
sudo -Hu vagrant cp /vagrant/conf/bitcoin.conf "$bitcoin_data_dir"

# Get Bitcoin
echo_log "Getting bitcoin"
sudo -Hu vagrant /home/vagrant/tools/BTC_resync

echo_log "complete"
echo "Bootstrap ends at "`date`
bootstrap_end=`date +%s`
echo "Bootstrap execution time is "$((bootstrap_end-bootstrap_start))" seconds"
echo "$0 all done!"
