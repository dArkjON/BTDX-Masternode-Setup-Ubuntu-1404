# Bitcloud (BTDX) Masternode - Build Docker Image

The Dockerfile will install all required stuff to run a Bitcloud (BTDX) Masternode and is based on script btdxsetup.sh (see: https://github.com/dArkjON/BTDX-Masternode-Setup-Ubuntu-1404/blob/master/btdxsetup.sh)

## Requirements
- Linux Ubuntu 16.04 LTS
- Running as docker host server (package docker-ce installed)
```
apt-get update
apt-get upgrade -y
apt-get install docker-ce -y
```

## Needed files
- Dockerfile
- bitcloud.conf
- bitcloud.sv.conf
- start.sh

## Allocating 2GB Swapfile
Create a swapfile to speed up the building process. Recommended if not enough RAM available on your docker host server.
```
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

## Build docker image
```
docker build [--build-arg BTDXPWD='<bitcloud user pwd>'] -t btdx-masternode .
```

## Push docker image to hub.docker
```
docker tag btdx-masternode <repository>/btdx-masternode
docker login -u <repository> -p"<PWD>"
docker push <repository>/btdx-masternode:<tag>
```
