#!/bin/bash

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='bitcloud.conf'
CONFIGFOLDER='/root/.bitcloud'
COIN_DAEMON='bitcloudd'
COIN_CLI='bitcloud-cli'
COIN_PATH='/usr/local/bin/'
COIN_RELEASE='https://github.com/LIMXTEC/Bitcloud/releases/download/2.1.0.0/linux.Ubuntu.16.04.LTS-static-libstdc.tar.gz'
COIN_ARCHIVE=$(echo $COIN_RELEASE | awk -F'/' '{print $NF}')
PHYS_MEM=$(echo $(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024))))
COIN_NAME='BITCLOUD'
COIN_PORT=8329
RPC_PORT=8330

NODEIP=$(curl -s4 icanhazip.com)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function download_node() {
    echo -e "Prepare to download ${GREEN}$COIN_NAME${NC}."
    cd $TMP_FOLDER >/dev/null 2>&1
    wget -q $COIN_RELEASE
    compile_error
    tar xvzf $COIN_ARCHIVE >/dev/null 2>&1
    cd $TMP_FOLDER
    chmod +x $COIN_DAEMON $COIN_CLI
    cp $COIN_DAEMON $COIN_CLI $COIN_PATH >/dev/null 2>&1
    cd ~ >/dev/null 2>&1
    rm -rf $TMP_FOLDER >/dev/null 2>&1
    clear
}

function configure_systemd() {
cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    sleep 3
    systemctl start $COIN_NAME.service
    systemctl enable $COIN_NAME.service >/dev/null 2>&1
    
    if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
        echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
        echo -e "${GREEN}systemctl start $COIN_NAME.service"
        echo -e "systemctl status $COIN_NAME.service"
        echo -e "less /var/log/syslog${NC}"
        exit 1
    fi
}

function create_config() {
    mkdir $CONFIGFOLDER >/dev/null 2>&1
    RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w16 | head -n1)
    RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w64 | head -n1)
cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=0
EOF
}

function create_key() {
    echo -e "Enter your ${RED}$COIN_NAME Masternode Private Key${NC}. Leave it blank to generate a new ${RED}Masternode Private Key${NC} for you:"
    read -e COINKEY
    if [[ -z "$COINKEY" ]]; then
        $COIN_PATH$COIN_DAEMON -daemon
    sleep 30
    if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
        echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
        exit 1
    fi
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
    if [ "$?" -gt "0" ]; then
        echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
        sleep 30
        COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
    fi
    $COIN_PATH$COIN_CLI stop
fi
clear
}

function update_config() {
    sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=64
masternode=1
externalip=$NODEIP:$COIN_PORT
masternodeaddr=127.0.0.1:$COIN_PORT
masternodeprivkey=$COINKEY
addnode=104.236.58.131
addnode=139.178.39.171
addnode=144.202.43.195
addnode=150.101.218.47
addnode=176.53.236.159
addnode=176.9.28.175
addnode=185.231.68.157
addnode=188.40.139.134
addnode=192.99.45.124
addnode=212.237.211.107
addnode=212.86.109.119
addnode=213.108.119.84
addnode=213.109.160.40
addnode=37.120.186.85
addnode=37.61.146.170
addnode=45.133.9.230
addnode=46.254.64.201
addnode=46.37.82.42
addnode=5.39.99.48
addnode=51.15.37.166
addnode=51.79.4.48
addnode=51.79.4.49
addnode=51.79.4.50
addnode=51.79.4.51
addnode=51.81.102.231
addnode=80.211.216.131
addnode=80.211.243.204
addnode=80.241.214.136
addnode=85.195.232.197
addnode=94.130.29.243
addnode=94.130.29.244
addnode=94.130.29.246
addnode=94.130.29.248
addnode=94.130.29.249
addnode=94.130.29.250
addnode=94.16.117.241
addnode=94.16.117.243
addnode=94.16.117.247
addnode=94.16.117.251
addnode=94.16.118.13
addnode=94.16.118.22
addnode=94.16.118.64
addnode=94.177.239.150
addnode=94.177.254.48
addnode=95.179.140.91
addnode=95.216.247.54
addnode=95.217.79.132
EOF
}

function enable_firewall() {
    echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
    ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null 2>&1
    ufw allow ssh comment "SSH" >/dev/null 2>&1
    ufw limit ssh/tcp >/dev/null 2>&1
    ufw default allow outgoing >/dev/null 2>&1
    echo "y" | ufw enable >/dev/null 2>&1
    sleep 3
    clear
}

function get_ip() {
    declare -a NODE_IPS
    for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
    do
        NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
    done
    
    if [ ${#NODE_IPS[@]} -gt 1 ]; then
        echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
        INDEX=0
        for ip in "${NODE_IPS[@]}"
        do
            echo ${INDEX} $ip
            let INDEX=${INDEX}+1
        done
        read -e choose_ip
        NODEIP=${NODE_IPS[$choose_ip]}
    else
        NODEIP=${NODE_IPS[0]}
    fi
}

function compile_error() {
if [ "$?" -gt "0" ]; then
    echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
    exit 1
fi
}

function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
    echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}$0 must be run as root.${NC}"
    exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ]; then
    echo -e "${RED}$COIN_NAME is already installed.${NC}"
    exit 1
fi
}

function prepare_system() {
    echo -e "Prepare the system to install ${GREEN}$COIN_NAME${NC} master node."
    apt-get update >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get update >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
    apt install -y software-properties-common >/dev/null 2>&1
    echo -e "${GREEN}Adding bitcoin PPA repository"
    apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
    echo -e "Installing required packages, it may take some time to finish.${NC}"
    apt-get update >/dev/null 2>&1
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
    build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
    libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
    libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5 >/dev/null 2>&1
    if [ "$?" -gt "0" ]; then
        echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
        echo "apt-get update"
        echo "apt -y install software-properties-common"
        echo "apt-add-repository -y ppa:bitcoin/bitcoin"
        echo "apt-get update"
        echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
        libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
        bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5"
        exit 1
    fi
    clear
}

function create_swap() {
    SWAP_FILE=$(free -m | grep -i swap | wc -l)
    if [[ $SWAP_FILE == 0 ]]; then
        read -e -p "Is your VPS Provider allowing to create SWAP file? If not sure hit enter! [Y/n] : " swapallowed
        if [[ ("$swapallowed" == "y" || "$swapallowed" == "Y") ]]; then
            echo "Creating SWAP file..."
            sudo touch /mnt/swap.img >/dev/null 2>&1
            sudo chmod 0600 /mnt/swap.img >/dev/null 2>&1
            dd if=/dev/zero of=/mnt/swap.img bs=1024k count=$PHYS_MEM >/dev/null 2>&1
            sudo mkswap /mnt/swap.img >/dev/null 2>&1
            sudo swapon /mnt/swap.img >/dev/null 2>&1
            sudo echo "/mnt/swap.img none swap sw 0 0" >> /etc/fstab >/dev/null 2>&1
            clear
        fi
    fi
}

function important_information() {
    echo -e "================================================================================================================================"
    echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
    echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
    echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
    echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
    echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
    echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
    echo -e "Please check ${RED}$COIN_NAME${NC} daemon is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
    echo -e "Use ${RED}$COIN_CLI masternode status${NC} to check your MN."
    echo -e "================================================================================================================================"
}

function setup_node() {
    get_ip
    create_config
    create_key
    update_config
    enable_firewall
    configure_systemd
}

##### Main #####
clear

checks
create_swap
prepare_system
download_node
setup_node
important_information
