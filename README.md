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
* Ubuntu 16.04
* Ubuntu 14.04
* ...

### Download and start the script
Login as root, then do:

```
wget https://raw.githubusercontent.com/LIMXTEC/BTDX-Masternode-Setup-Ubuntu-1404/master/btdx-docker.sh
chmod +x btdx-docker.sh
./btdx-docker.sh
```

### For more details to docker related stuff have a look at:
* BTDX-Masternode-Setup-Ubuntu-1404/BUILD_README.md
* BTDX-Masternode-Setup-Ubuntu-1404/RUN_README.md
