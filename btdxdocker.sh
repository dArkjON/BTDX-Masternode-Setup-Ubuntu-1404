#!/bin/bash
set -u

DOCKER_REPO='dalijolijo'

#
# Set bitcloud user pwd and masternode genkey
#
echo '*** Step 0/10 - User input ***'
echo -n "Enter new password for [bitcloud] user and Hit [ENTER]: "
read PWD
echo -n "Enter your masternode genkey respond and Hit [ENTER]: "
read MN_KEY

#
# Check distro version (TODO)
#
#cat /etc/issue
echo 'Checking OS version.'
if [[ -r /etc/os-release ]]; then
		. /etc/os-release
		if [[ "${VERSION_ID}" != "16.04" ]]; then
			echo "This script only supports ubuntu 16.04 LTS, exiting."
			exit 1
		fi
fi


#
# Installation of docker package
#
apt-get update
apt-get upgrade -y
apt-get install docker.io
apt-get install docker.io -y
docker pull ${DOCKER_REPO}/btdx-masternode
docker run -p 8329:8329 -p 51473:51473 --name btdx-masternode -e BTDXPWD='${PWD}' -e MN_KEY='${MN_KEY}' -v /home/bitcloud:/home/bitcloud:rw -d ${DOCKER_REPO}/btdx-masternode
