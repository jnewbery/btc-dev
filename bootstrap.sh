#!/usr/bin/env bash
set -Eeux
set -o posix
set -o pipefail

declare -r guest_log="/vagrant/guest_logs/vagrant_mmc_bootstrap.log"

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

# Get user argument
# Reset in case getopts has been used previously in the shell.
OPTIND=1 

# Initialize our own variables:
user=""

while getopts "u:" opt; do
    case "$opt" in
    u)  user=$OPTARG
        ;;
    esac
done

echo_log "user=$user, leftover variables: $@"

# add 2G swap to avoid around annoying ENOMEM problems (does not persist across reboot)
echo_log "create swap"
mkdir -p /var/cache/swap/
dd if=/dev/zero of=/var/cache/swap/swap0 bs=1M count=2048
chmod 0600 /var/cache/swap/swap0
mkswap /var/cache/swap/swap0
swapon /var/cache/swap/swap0

# baseline system prep
echo_log "base system update"
add-apt-repository -y ppa:fkrull/deadsnakes
add-apt-repository -y ppa:pi-rho/dev
apt-get -y update

# Get stuff:
#
# - ack
# - ccache
# - gdp
# - git
# - pip
# - python 3.5
# - tmux 2.4
# - vim

apt-get -y install ack-grep ccache gdb git python3.5 python3-pip tmux-next vim xdg-utils
apt-get -f remove -y tmux
rm -f /usr/bin/tmux
ln -s /usr/bin/tmux-next /usr/bin/tmux

# Get Python stuff:
#
# - ipython
pip3 install ipython

# Add the best dotfiles in the world
cd /home/$user
rm -rf .dotfiles
git clone https://github.com/jnewbery/dotfiles.git .dotfiles
chown -R $user:$user .dotfiles
cd .dotfiles
sudo -Hu $user /home/$user/.dotfiles/infect

# BITCOIN specific
##################

# Get stuff:
#
# - autoreconf
# - Boostlib
# - Open SSL dev libraries
# - Python 3 zmq for running the python test suite
# - libdb_cxx
# - libevent
# - pkg-config
apt-get -y install dh-autoreconf libboost-all-dev libevent-dev libssl-dev pkg-config python3-zmq

# Get berkely db v4.8
apt-get -y install software-properties-common
add-apt-repository -y ppa:bitcoin/bitcoin
apt-get -y update
apt-get -y install libdb4.8-dev libdb4.8++-dev

# add blockchain tools to path
sudo -Hu $user cp -r /vagrant/tools /home/$user/
cat >>/home/$user/.bashrc <<EOL

# add blockchain tools to path
PATH=\$PATH:/home/$user/tools
EOL

# helpful alises
cat >>/home/$user/.bashrc <<'EOL'

# Handy bitcoin aliases
alias bd='bitcoind' #starts bitcoin
alias bcli='bitcoin-cli'
alias bb='BTC_build' #builds bitcoin
alias bs="(pgrep bitcoind > /dev/null && bcli stop) || bd" # stop/start bitcoind
alias bst='BTC_status'
EOL

# Get the python-bitcoinrpc library
echo_log "Getting python-bitcoinrpc"
apt-get -y install python-pip python-dev build-essential 
pip install --upgrade pip
pip install --upgrade virtualenv
pip install python-bitcoinrpc

# Make bitcoin data directory
declare -r bitcoin_data_dir="/home/$user/.bitcoin"
mkdir "$bitcoin_data_dir"
chown -R $user:$user "$bitcoin_data_dir"
sudo -Hu $user cp /vagrant/conf/bitcoin.conf "$bitcoin_data_dir"

# Get Bitcoin
echo_log "Getting bitcoin"
sudo -Hu $user /home/$user/tools/BTC_resync

echo_log "complete"
echo "Bootstrap ends at "`date`
bootstrap_end=`date +%s`
echo "Bootstrap execution time is "$((bootstrap_end-bootstrap_start))" seconds"
echo "$0 all done!"

