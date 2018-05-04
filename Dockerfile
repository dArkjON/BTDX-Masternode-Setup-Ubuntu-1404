# Bitcloud (BTDX) Masternode - Dockerfile (05-2018)
#
# The Dockerfile will install all required stuff to run a Bitcloud (BTDX) Masternode and is based on script btdxsetup.sh (see: https://github.com/dArkjON/BTDX-Masternode-Setup-Ubuntu-1404/blob/master/btdxsetup.sh)
# Bitcloud Repo : https://github.com/LIMXTEC/Bitcloud
# E-Mail: info@xxx
# 
# To build a docker image for bsd-masternode from the Dockerfile the bitcloud.conf is also needed.
# See BUILD_README.md for further steps.

# Use an official Ubuntu runtime as a parent image
FROM ubuntu:16.04

LABEL maintainer="Jon D. (dArkjON), David B. (dalijolijo)"
LABEL version="0.1"

# Make ports available to the world outside this container
EXPOSE 8886 8800

USER root

# Change sh to bash
SHELL ["/bin/bash", "-c"]

# Define environment variable
ENV BTDXPWD "bitcloud"

RUN echo '**********************************' && \
    echo '*** Bitcloud (BTDX) Masternode ***' && \
    echo '**********************************'

#
# Step 1/10 - creating bitcloud user
#
RUN echo '*** Step 1/10 - creating bitcloud user ***' && \
    adduser --disabled-password --gecos "" bitcloud && \
    usermod -a -G sudo,bitcloud bitcloud && \
    echo bitcloud:$BTDXPWD | chpasswd && \
    echo '*** Done 1/10 ***'

#
# Step 2/10 - Allocating 2GB Swapfile
#
RUN echo '*** Step 2/10 - Allocating 2GB Swapfile ***' && \
    echo 'not needed: skipped' && \
    echo '*** Done 2/10 ***'

#
# Step 3/10 - Running updates and installing required packages
#
RUN echo '*** Step 3/10 - Running updates and installing required packages ***' && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y  apt-utils \
                        autoconf \
                        automake \
                        autotools-dev \
                        build-essential \
                        curl \
                        git \
                        libboost-all-dev \
                        libevent-dev \
                        libminiupnpc-dev \
                        libssl-dev \
                        libtool \
                        libzmq5-dev \
                        pkg-config \
                        software-properties-common \
                        sudo \
                        supervisor \
                        vim \
                        wget && \
    add-apt-repository -y ppa:bitcoin/bitcoin && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y  libdb4.8-dev \
                        libdb4.8++-dev && \
    echo '*** Done 3/10 ***'

#
# Step 4/10 - Cloning and Compiling Bitcloud Wallet
#
RUN echo '*** Step 4/10 - Cloning and Compiling Bitcloud Wallet ***' && \
    cd && \
    echo "Execute a git clone of LIMXTEC/Bitcloud. Please wait..." && \
    git clone --branch v0.14 --depth 1 https://github.com/LIMXTEC/Bitcloud && \
    cd Bitcloud && \
    ./autogen.sh && \
    ./configure --disable-dependency-tracking --enable-tests=no --without-gui && \
    make && \
    cd && \
    cd Bitcloud/src && \
    strip bitcloudd && \
    cp bitcloudd /usr/local/bin && \
    strip bitcloud-cli && \
    cp bitcloud-cli /usr/local/bin && \
    chmod 775 /usr/local/bin/bitcloud* && \   
    cd && \
    rm -rf Bitcloud && \
    echo '*** Done 4/10 ***'

#
# Step 5/10 - Adding firewall rules
#
RUN echo '*** Step 5/10 - Adding firewall rules ***' && \
    echo 'must be configured on the socker host: skipped' && \
    echo '*** Done 5/10 ***'

#
# Step 6/10 - Configure bitcloud.conf
#
COPY bitcloud.conf /tmp
RUN echo '*** Step 6/10 - Configure bitcloud.conf ***' && \
    chown bitcloud:bitcloud /tmp/bitcloud.conf && \
    sudo -u bitcloud mkdir -p /home/bitcloud/.bitcloud && \
    sudo -u bitcloud cp /tmp/bitcloud.conf /home/bitcloud/.bitcloud/ && \
    echo '*** Done 6/10 ***'

#
# Step 7/10 - Adding bitcloudd daemon as a service
#
RUN echo '*** Step 7/10 - Adding bitcloudd daemon ***' && \
    echo 'docker not supported systemd: skipped' && \
    echo '*** Done 7/10 ***'

#
# Supervisor Configuration
#
COPY *.sv.conf /etc/supervisor/conf.d/

#
# Logging outside docker container
#
VOLUME /var/log

#
# Start script
#
COPY start.sh /usr/local/bin/start.sh
RUN \
  rm -f /var/log/access.log && mkfifo -m 0666 /var/log/access.log && \
  chmod 755 /usr/local/bin/*

ENV TERM linux
CMD ["/usr/local/bin/start.sh"]
