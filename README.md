# BTDX-Masternode-Setup
## OPTION 1: Installation with script

This script will help you to setup a remote Bitcloud Masternode and need your `masternode genkey` output from your local wallet.
***Only working for Linux Ubuntu 14.04 LTS***

### Download and start the script
Login as root, then do:
```
wget https://raw.githubusercontent.com/LIMXTEC/BTDX-Masternode-Setup-Ubuntu-1404/master/btdxsetup.sh
chmod +x btdxsetup.sh
./btdxsetup.sh
```

## OPTION 2: Deploy as a docker container

Support for the following distribution versions:
* x86_64-centos-7
* x86_64-fedora-26
* x86_64-fedora-27
* x86_64-fedora-28
* x86_64-debian-wheezy
* x86_64-debian-jessie
* x86_64-debian-stretch
* x86_64-debian-buster
* x86_64-ubuntu-trusty
* x86_64-ubuntu-xenial (tested)
* x86_64-ubuntu-bionic
* x86_64-ubuntu-artful

### Download and execute the docker-ce installation script

Download and execute the automated docker-ce installation script - maintained by the Docker project.

```
sudo curl -sSL https://get.docker.com | sh
```

### Download and start the script
Login as root, then do:

```
wget https://raw.githubusercontent.com/dalijolijo/BTDX-Masternode-Setup-Ubuntu-1404/master/btdx-docker.sh
chmod +x btdx-docker.sh
./btdx-docker.sh
```

### For more details to docker related stuff have a look at:
* BTDX-Masternode-Setup-Ubuntu-1404/BUILD_README.md
* BTDX-Masternode-Setup-Ubuntu-1404/RUN_README.md
