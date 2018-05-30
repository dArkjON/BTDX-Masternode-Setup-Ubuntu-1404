# Bitcloud (BTDX) Masternode - Dockerfile (05-2018)
#
# The Dockerfile will install all required stuff to run a Bitcloud (BTDX) Masternode and is based on script btdxsetup.sh (see: https://github.com/dArkjON/BTDX-Masternode-Setup-Ubuntu-1404/blob/master/btdxsetup.sh)
# Bitcloud Repo : https://github.com/LIMXTEC/Bitcloud
# E-Mail: info@bit-cloud.info
# 
# To build a docker image for btdx-masternode from the Dockerfile the bitcloud.conf is also needed.
# See BUILD_README.md for further steps.

# Use an official Ubuntu runtime as a parent image
FROM ubuntu:16.04

LABEL maintainer="Jon D. (dArkjON), David B. (dalijolijo)"
LABEL version="0.2"

# Make ports available to the world outside this container
# DefaultPort = 8329
# RPCPort = 8330
# TorPort = 9051
EXPOSE 8329 8330 9051

USER root

# Change sh to bash
SHELL ["/bin/bash", "-c"]

# Define environment variable
ENV BTDXPWD "bitcloud"

RUN echo '*** Bitcloud (BTDX) Masternode ***'

#
# Creating bitcloud user
#
RUN echo '*** Creating bitcloud user ***' && \
    adduser --disabled-password --gecos "" bitcloud && \
    usermod -a -G sudo,bitcloud bitcloud && \
    echo bitcloud:$BTDXPWD | chpasswd

#
# Running updates and installing required packages
#
# nodejs nodejs-legacy redis-server npm
RUN echo '*** Running updates and installing required packages ***' && \
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
                        libdb4.8++-dev

#
# Cloning and Compiling Bitcloud Wallet
#
RUN echo '*** Cloning and Compiling Bitcloud Wallet ***' && \
    cd && \
    echo "Execute a git clone of LIMXTEC/Bitcloud. Please wait..." && \
    git clone https://github.com/LIMXTEC/Bitcloud.git && \
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
    strip bitcloud-tx && \
    cp bitcloud-tx /usr/local/bin && \
    chmod 775 /usr/local/bin/bitcloud* && \   
    cd && \
    rm -rf Bitcloud

#
# Copy Supervisor Configuration and bitcloud.conf
#
RUN echo '*** Copy Supervisor Configuration and bitcloud.conf ***'
COPY *.sv.conf /etc/supervisor/conf.d/
COPY bitcloud.conf /tmp

#
# Logging outside docker container
#
VOLUME /var/log

#
# Start script
#
RUN echo '*** Copy start script ***'
COPY start.sh /usr/local/bin/start.sh
RUN rm -f /var/log/access.log && mkfifo -m 0666 /var/log/access.log && \
    chmod 755 /usr/local/bin/*

ENV TERM linux
CMD ["/usr/local/bin/start.sh"]
