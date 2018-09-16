# BTDX-Masternode-Setup
## OPTION 1: Installation/update with script

This script will help you to setup a remote Bitcloud Masternode and need your `masternode genkey` output from your local wallet.
***Only working for Linux Ubuntu 16.04***

### Download and start the setup script
Login as root, then do:
```
sudo bash -c "$(curl -fsSL https://github.com/LIMXTEC/BTDX-Masternode-Setup/raw/master/masternode-setup.sh)"
```

### Optional: Download and start the update script
Important: Use this script only if you run our [**masternode setup script**](https://github.com/LIMXTEC/BTDX-Masternode-Setup/raw/master/masternode-setup.sh)\
Login as root, then do:
```
sudo bash -c "$(curl -fsSL https://github.com/LIMXTEC/BTDX-Masternode-Setup/raw/master/masternode-update.sh)"
```

### Optional: Download and start the bootstrap script
Every 3 hours will be our BitCloud bootstrap refreshed. To get latest bootstrap/blockchain files, you need to login as root.
Used path in this bootstrap script is **/root/.bitcloud**
```
sudo bash -c "$(curl -fsSL https://github.com/LIMXTEC/BTDX-Masternode-Setup/raw/master/bootstrap.sh)"
```

## OPTION 2: Deploy as a docker container

Support for the following distribution versions:
* CentOS 7.4 (x86_64-centos-7)
* Fedora 26 (x86_64-fedora-26)
* Fedora 27 (x86_64-fedora-27) - tested
* Fedora 28 (x86_64-fedora-28) - tested
* Debian 7 (x86_64-debian-wheezy)
* Debian 8 (x86_64-debian-jessie) - tested
* Debian 9 (x86_64-debian-stretch) - tested
* Debian 10 (x86_64-debian-buster) - tested
* Ubuntu 14.04 LTS (x86_64-ubuntu-trusty) - tested
* Ubuntu 16.04 LTS (x86_64-ubuntu-xenial) - tested
* Ubuntu 17.10 (x86_64-ubuntu-artful)
* Ubuntu 18.04 LTS (x86_64-ubuntu-bionic) - tested

### Download and execute the docker-ce installation script

Download and execute the automated docker-ce installation script - maintained by the Docker project.

```
sudo curl -sSL https://get.docker.com | sh
```

### Download and start the script
Login as root, then do:

```
sudo bash -c "$(curl -fsSL https://github.com/LIMXTEC/BTDX-Masternode-Setup/raw/master/btdx-docker.sh)"
```

### For more details to docker related stuff have a look at:
* BTDX-Masternode-Setup/BUILD_README.md
* BTDX-Masternode-Setup/RUN_README.md
