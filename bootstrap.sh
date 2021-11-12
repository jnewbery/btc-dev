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

# Remind user to update dotfiles
cat >>/home/vagrant/.bashrc <<EOL

echo "Don't forget to update your dotfiles!"
EOL

# Get stuff:
echo_log "base system update"
apt-get -y update

apt-get -y install ack-grep  # ack
apt-get -y install ccache  # ccache
apt-get -y install clang  # clang
apt-get -y install dh-autoreconf  # autoreconf
apt-get -y install gdb  # gnu debugger
apt-get -y install libboost-all-dev  # boost
apt-get -y install libdb-dev libdb++-dev  # bdb
apt-get -y install libevent-dev  # libevent
apt-get -y install libprotobuf-dev protobuf-compiler  # protobuf
apt-get -y install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools  # qt
apt-get -y install libsqlite3-dev  # sqlite
apt-get -y install pkg-config  # pkg-config
apt-get -y install python-dev  # python-bitcoinrpc
apt-get -y install python-is-python3  # ipython
apt-get -y install python3-pip  # pip3
apt-get -y install python3-zmq libzmq3-dev  # zmq
apt-get -y install software-properties-common  # software properties ??
apt-get -y install xdg-utils  # xdg-utils

# Get python stuff
pip3 install --upgrade pip
pip3 install ipython  # ipython
pip3 install python-bitcoinrpc  # python-bitcoinrpc

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
