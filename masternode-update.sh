#!/bin/bash

# Variables
RED_TEXT=`tput setaf 1`
GREEN_TEXT=`tput setaf 2`
RESET_TEXT=`tput sgr0`
REQUIRED_UBUNTU_VERSION="16.04"
COIN_NAME='BITCLOUD'
CONFIG_FILE='bitcloud.conf'
CONFIGFOLDER='/root/.bitcloud'
COIN_DAEMON='bitcloudd'
COIN_CLI='bitcloud-cli'
COIN_PATH='/usr/local/bin/'
COIN_CHAIN='https://bitcloud.network/files/blockchain.tar.gz'
SERVICE_PATH='/etc/systemd/system/BITCLOUD.service'
# If you have not used my Masternode install script, please change path to bitcloud-cli & bitcloudd files!
DATA_PATH=/usr/local/bin

# Required Ubuntu Version check
clear
echo -n 'Checking Ubuntu Linux Version...'
if [[ `lsb_release -rs` == $REQUIRED_UBUNTU_VERSION ]]
then
	echo "${GREEN_TEXT} 16.04 OK ${RESET_TEXT}"; echo ""
else
	echo "${RED_TEXT} Your Server is not running Ubuntu $REQUIRED_UBUNTU_VERSION, please upgrade to Ubuntu $REQUIRED_UBUNTU_VERSION ! The script will be terminated... ${RESET_TEXT}"; echo ""
	exit
fi

# Stop current running masternode
echo -e 'Stopping Masternode...'
systemctl stop $COIN_NAME.service > /dev/null 2>&1

# Install CURL, Download current version, extract and copy
echo -e 'Downloading, extracting and copying files.'
sudo apt-get install curl -y > /dev/null 2>&1
CORE_URL=$(curl -s https://api.github.com/repos/LIMXTEC/Bitcloud/releases/latest | grep -i "linux.Ubuntu.16.04.LTS-static-libstdc.tar.gz" | grep -i "browser_download_url" | awk -F" " '{print $2}' | sed 's/"//g')
CORE_FILE=$(curl -s https://api.github.com/repos/LIMXTEC/Bitcloud/releases/latest | grep -i "linux.Ubuntu.16.04.LTS-static-libstdc.tar.gz" | grep -i "name" | awk -F" " '{print $2}' | sed 's/"//g' | sed 's/,//g')
cd ~
wget $CORE_URL > /dev/null 2>&1
tar -xvf $CORE_FILE > /dev/null 2>&1

strip bitcloud{d,-cli,-tx} > /dev/null 2>&1
cp -f bitcloud{d,-cli} /usr/local/bin > /dev/null 2>&1

# Delete Files
echo -e 'Deleting unnecessary files...'
rm -f ~/$CORE_FILE > /dev/null 2>&1
rm -f ~/bitcloud{d,-cli,-tx,-qt} > /dev/null 2>&1

# Start Masternode running current version
echo -e "Starting Masternode with current version."
systemctl start $COIN_NAME.service

# Show Version and Masternde Info
echo -e "Getting Masternode Output."
sleep 5
echo ""
bitcloud-cli getinfo
rm -f ~/masternode-update.sh
