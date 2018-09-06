#!/bin/bash
set -u

GIT_REPO="dalijolijo"
GIT_PROJECT="BTDX-Masternode-Setup"
DOCKER_REPO="dalijolijo"
IMAGE_NAME="btdx-masternode"
IMAGE_TAG="2.1.0.0" #BTDX Version 2.1.0.0
CONFIG="/home/bitcloud/.bitcloud/bitcloud.conf"
CONTAINER_NAME="btdx-masternode"
DEFAULT_PORT="8329"
RPC_PORT="8330"
TOR_PORT="9050"
WEB="bit-cloud.info/files" # without "https://" and without the last "/" (only HTTPS accepted)
BOOTSTRAP="bootstrap.tar.gz"
IP=$(curl -s https://bit-cloud.info/showip.php)

#
# Color definitions
#
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COL='\033[0m'
BTDX_COL='\033[0;36m'

#
# Check if bitcloud.conf already exist. Set masternode genkey
#
clear
REUSE="No"
printf "\nDOCKER SETUP FOR ${BTDX_COL}BITCLOUD (BTDX) V${IMAGE_TAG}${NO_COL} MASTERNODE SERVER\n"
printf "\nSetup Config file"
printf "\n-----------------\n"
if [ -f "$CONFIG" ]
then
        printf "\nFound $CONFIG on your system.\n"
        printf "\nDo you want to re-use this existing config file?\n" 
        printf "Enter [Y]es or [N]o and Hit [ENTER]: "
        read REUSE
fi

if [[ $REUSE =~ "N" ]] || [[ $REUSE =~ "n" ]]; then
	read -e -p "Is this IP-address $IP your VPS IP-address? [Y/n]: " ipaddress
        if [[ ("$ipaddress" == "n" || "$ipaddress" == "N") ]]; then
		printf "\nEnter the IP-address of your ${BTDX_COL}BitCloud${NO_COL} Masternode VPS and Hit [ENTER]: "
		read BTDX_IP
	else
		BTDX_IP=$(echo $IP)
	fi
        printf "Enter your ${BTDX_COL}BitCloud${NO_COL} Masternode genkey respond and Hit [ENTER]: "
        read MN_KEY
else
        source $CONFIG
        BTDX_IP=$(echo $externalip)
        MN_KEY=$(echo $masternodeprivkey)
fi


#
# Docker Installation
#
if ! type "docker" > /dev/null; then
  curl -fsSL https://get.docker.com | sh
fi

#
# Firewall Setup
#
printf "\nDownload needed Helper-Scripts"
printf "\n------------------------------\n"
wget https://raw.githubusercontent.com/${GIT_REPO}/${GIT_PROJECT}/master/check_os.sh -O check_os.sh
chmod +x ./check_os.sh
source ./check_os.sh
rm ./check_os.sh
wget https://raw.githubusercontent.com/${GIT_REPO}/${GIT_PROJECT}/master/firewall_config.sh -O firewall_config.sh
chmod +x ./firewall_config.sh
source ./firewall_config.sh ${DEFAULT_PORT} ${RPC_PORT} ${TOR_PORT}
rm ./firewall_config.sh


#
# Pull docker images and run the docker container
#
printf "\nStart Docker container"
printf "\n----------------------\n"
sudo docker ps | grep ${CONTAINER_NAME} >/dev/null
if [ $? -eq 0 ];then
    printf "${RED}Conflict! The container name \'${CONTAINER_NAME}\' is already in use.${NO_COL}\n"
    printf "\nDo you want to stop the running container to start the new one?\n"
    printf "Enter [Y]es or [N]o and Hit [ENTER]: "
    read STOP

    if [[ $STOP =~ "Y" ]] || [[ $STOP =~ "y" ]]; then
        docker stop ${CONTAINER_NAME}
    else
	printf "\nDocker Setup Result"
        printf "\n----------------------\n"
        printf "${RED}Canceled the Docker Setup without starting ${BTDX_COL}BitCloud${RED} Masternode Docker Container.${NO_COL}\n\n"
	exit 1
    fi
fi
docker rm ${CONTAINER_NAME} >/dev/null
docker pull ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
docker run \
 --rm \
 -p ${DEFAULT_PORT}:${DEFAULT_PORT} \
 -p ${RPC_PORT}:${RPC_PORT} \
 -p ${TOR_PORT}:${TOR_PORT} \
 --name ${CONTAINER_NAME} \
 -e BTDX_IP="${BTDX_IP}" \
 -e MN_KEY="${MN_KEY}" \
 -e WEB="${WEB}" \
 -e BOOTSTRAP="${BOOTSTRAP}" \
 -v /home/bitcloud:/home/bitcloud:rw \
 -d ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

#
# Show result and give user instructions
#
clear
printf "\nDocker Setup Result"
printf "\n----------------------\n"
sudo docker ps | grep ${CONTAINER_NAME} >/dev/null
if [ $? -ne 0 ];then
    printf "${RED}Sorry! Something went wrong. :(${NO_COL}\n"
else
    printf "${GREEN}GREAT! Your ${BTDX_COL}BitCloud (v${IMAGE_TAG}) ${GREEN} Masternode Docker Container is running now! :)${NO_COL}\n"
    printf "\nShow your running docker container \'${CONTAINER_NAME}\' with 'docker ps'\n"
    sudo docker ps | grep ${CONTAINER_NAME}
    printf "\nJump inside the ${BTDX_COL}BitCloud (BTDX)${NO_COL} Masternode Docker Container with ${GREEN}'docker exec -it ${CONTAINER_NAME} bash'${NO_COL}\n"
    printf "\nCheck Log Output of ${BTDX_COL}BitCloud (BTDX)${NO_COL} Masternode with ${GREEN}'docker logs ${CONTAINER_NAME}'${NO_COL}\n"
    printf "${GREEN}HAVE FUN!${NO_COL}\n\n"
fi
