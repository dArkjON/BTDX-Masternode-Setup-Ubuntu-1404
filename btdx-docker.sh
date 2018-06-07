#!/bin/bash
set -u

DOCKER_REPO="dalijolijo"
CONFIG="/home/bitcloud/.bitcloud/bitcloud.conf"
DEFAULT_PORT="8329"
RPC_PORT="8330"
TOR_PORT="9050"

#
# Check if bitcloud.conf already exist. Set bitcloud user pwd and masternode genkey
#
REUSE="No"
if [ -f "$CONFIG" ]
then
        echo -n "Found $CONFIG on your system. Do you want to re-use this existing config file? Enter Yes or No and Hit [ENTER]: "
        read REUSE
fi

if [[ $REUSE =~ "N" ]] || [[ $REUSE =~ "n" ]]; then
        echo -n "Enter new password for [bitcloud] user and Hit [ENTER]: "
        read BTDXPWD
        echo -n "Enter your bitcloud masternode genkey respond and Hit [ENTER]: "
        read MN_KEY
else
        source $CONFIG
        BTDXPWD=$(echo $rpcpassword)
        MN_KEY=$(echo $masternodeprivkey)
fi

#
# Check distro version for further configurations (TODO)
#
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

#
# Configuration for Ubuntu/Debian/Mint
#
if [[ $OS =~ "Ubuntu" ]] || [[ $OS =~ "ubuntu" ]] || [[ $OS =~ "Debian" ]] || [[ $OS =~ "debian" ]] || [[ $OS =~ "Mint" ]] || [[ $OS =~ "mint" ]]; then
    echo "Configuration for $OS ($VER)..."
    
    #Check if firewall ufw is installed
    which ufw >/dev/null
    if [ $? -ne 0 ];then
        echo "Missing firewall (ufw) on your system."
        echo "Automated firewall setup will open the following ports: 22, ${DEFAULT_PORT}, ${RPC_PORT} and ${TOR_PORT}"
        echo -n "Do you want to install firewall (ufw) and execute automated firewall setup? Enter Yes or No and Hit [ENTER]: "
        read FIRECONF
    else
        echo "Found firewall ufw on your system. Automated firewall setup will open the following ports: 22, ${DEFAULT_PORT}, ${RPC_PORT} and ${TOR_PORT}"
        echo -n "Do you want to start automated firewall setup? Enter Yes or No and Hit [ENTER]: "
        read FIRECONF

        if [[ $FIRECONF =~ "Y" ]] || [[ $FIRECONF =~ "y" ]]; then
           #Installation of ufw, if not installed yet
           which ufw >/dev/null
           if [ $? -ne 0 ];then
               apt-get update
               sudo apt-get install -y ufw
           fi
           
           # Firewall settings
           echo "Setup firewall..."
           ufw logging on
           ufw allow 22/tcp
           ufw limit 22/tcp
           ufw allow ${DEFAULT_PORT}/tcp
           ufw allow ${RPC_PORT}/tcp
           ufw allow ${TOR_PORT}/tcp
           # if other services run on other ports, they will be blocked!
           #ufw default deny incoming
           ufw default allow outgoing
           yes | ufw enable
        fi
    fi

    # Installation further package
    echo "Install further packages..."
    apt-get update
    sudo apt-get install -y apt-transport-https \
                            ca-certificates \
                            curl \
                            software-properties-common
else
    echo "Automated firewall setup for $OS ($VER) not supported!"
    echo "Please open firewall ports 22, ${DEFAULT_PORT}, ${RPC_PORT} and ${TOR_PORT} manually."
    exit
fi

#
# Pull docker images and run the docker container
#
docker rm btdx-masternode
docker pull ${DOCKER_REPO}/btdx-masternode
docker run -p ${DEFAULT_PORT}:${DEFAULT_PORT} -p ${RPC_PORT}:${RPC_PORT} -p ${TOR_PORT}:${TOR_PORT} --name btdx-masternode -e BTDXPWD="${BTDXPWD}" -e MN_KEY="${MN_KEY}" -v /home/bitcloud:/home/bitcloud:rw -d ${DOCKER_REPO}/btdx-masternode
