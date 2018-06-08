#!/bin/bash
set -u

DOCKER_REPO="dalijolijo"
CONFIG="/home/bitcloud/.bitcloud/bitcloud.conf"
CONTAINER_NAME="btdx-masternode"
DEFAULT_PORT="8329"
RPC_PORT="8330"
TOR_PORT="9050"

#
# Check if bitcloud.conf already exist. Set bitcloud user pwd and masternode genkey
#
clear
REUSE="No"
printf "\nDOCKER SETUP FOR BITCLOUD (BTDX) RPC SERVER\n"
printf "\nSetup Config file"
printf "\n-----------------"
if [ -f "$CONFIG" ]
then
        printf "\nFound $CONFIG on your system.\n"
        printf "\nDo you want to re-use this existing config file?\n" 
        printf "Enter [Y]es or [N]o and Hit [ENTER]: "
        read REUSE
fi

if [[ $REUSE =~ "N" ]] || [[ $REUSE =~ "n" ]]; then
        printf "\nEnter new password for [bitcloud] user and Hit [ENTER]: "
        read BTDXPWD
        printf "Enter your bitcloud masternode genkey respond and Hit [ENTER]: "
        read MN_KEY
else
        source $CONFIG
        BTDXPWD=$(echo $rpcpassword)
        MN_KEY=$(echo $masternodeprivkey)
fi

#
# Check distro version for further configurations
#
printf "\nDocker Host Operating System"
printf "\n----------------------------\n"
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
printf "Found installed $OS ($VER)\n"

#
# Configuration for Ubuntu/Debian/Mint
#
printf "\nSetup Firewall"
printf "\n--------------\n"
if [[ $OS =~ "Ubuntu" ]] || [[ $OS =~ "ubuntu" ]] || [[ $OS =~ "Debian" ]] || [[ $OS =~ "debian" ]] || [[ $OS =~ "Mint" ]] || [[ $OS =~ "mint" ]]; then

    #Check if firewall ufw is installed
    which ufw >/dev/null
    if [ $? -ne 0 ];then
        printf "Missing firewall (ufw) on your system.\n"
        printf "Automated firewall setup will open the following ports: 22, ${DEFAULT_PORT}, ${RPC_PORT} and ${TOR_PORT}\n"
        printf "\nDo you want to install firewall (ufw) and execute automated firewall setup?\n"
        printf "Enter [Y]es or [N]o and Hit [ENTER]: "
        read FIRECONF
    else
        printf "Found firewall ufw on your system.\n"
        printf "Automated firewall setup will open the following ports: 22, ${DEFAULT_PORT}, ${RPC_PORT} and ${TOR_PORT}\n"
        printf "\nDo you want to start automated firewall setup?\n"
        printf "Enter [Y]es or [N]o and Hit [ENTER]: "
        read FIRECONF
    fi

    if [[ $FIRECONF =~ "Y" ]] || [[ $FIRECONF =~ "y" ]]; then
        #Installation of ufw, if not installed yet
        which ufw >/dev/null
        if [ $? -ne 0 ];then
           apt-get update
           sudo apt-get install -y ufw
        fi

        # Firewall settings
        printf "\nSetup firewall...\n"
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

    # Installation further package
    printf "\nPackages Setup"
    printf "\n--------------\n"
    printf "Install further packages...\n"
    apt-get update
    sudo apt-get install -y apt-transport-https \
                            ca-certificates \
                            curl \
                            software-properties-common
else
    printf "Automated firewall setup for $OS ($VER) not supported!\n"
    printf "Please open firewall ports 22, ${DEFAULT_PORT}, ${RPC_PORT} and ${TOR_PORT} manually.\n"
    exit
fi

#
# Pull docker images and run the docker container
#
printf "\nStart Docker container"
printf "\n----------------------\n"
sudo docker ps | grep ${CONTAINER_NAME} >/dev/null
if [ $? -eq 0 ];then
    printf "Conflict! The container name \'${CONTAINER_NAME}\' is already in use.\n"
    printf "\nDo you want to stop the running container to start the new one?\n"
    printf "Enter [Y]es or [N]o and Hit [ENTER]: "
    read STOP

    if [[ $STOP =~ "Y" ]] || [[ $STOP =~ "y" ]]; then
        docker stop ${CONTAINER_NAME}
    else
	printf "\nDocker Setup Result"
        printf "\n----------------------\n"
        printf "Canceled the Docker Setup without starting BitCloud Masternode Docker Container.\n\n"
	exit 1
    fi
fi
docker rm ${CONTAINER_NAME} >/dev/null
docker pull ${DOCKER_REPO}/btdx-masternode
docker run -p ${DEFAULT_PORT}:${DEFAULT_PORT} -p ${RPC_PORT}:${RPC_PORT} -p ${TOR_PORT}:${TOR_PORT} --name ${CONTAINER_NAME} -e BTDXPWD="${BTDXPWD}" -e MN_KEY="${MN_KEY}" -v /home/bitcloud:/home/bitcloud:rw -d ${DOCKER_REPO}/btdx-masternode

#
# Show result and give user instructions
#
clear
printf "\nDocker Setup Result"
printf "\n----------------------\n"
sudo docker ps | grep ${CONTAINER_NAME} >/dev/null
if [ $? -ne 0 ];then
    printf "Sorry! Something went wrong. :(\n"
else
    printf "GREAT! Your BitCloud Masternode Docker Container is running now! :)\n"
    printf "\nShow your running docker container \'${CONTAINER_NAME}\' with 'docker ps'\n"
    sudo docker ps | grep ${CONTAINER_NAME}
    printf "\nJump inside the docker container with 'docker exec -it ${CONTAINER_NAME} bash'\n"
    printf "HAVE FUN!\n\n"
fi
