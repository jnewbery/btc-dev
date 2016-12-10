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
apt-get -y update
apt-get -y install vim

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

# GNU debugger
apt-get -y install gdb

echo_log "complete"
echo "Bootstrap ends at "`date`
bootstrap_end=`date +%s`
echo "Bootstrap execution time is "$((bootstrap_end-bootstrap_start))" seconds"
echo "$0 all done!"

