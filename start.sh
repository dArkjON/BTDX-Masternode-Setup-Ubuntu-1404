#!/bin/bash
set -u

#
# Downloading bitcloud.conf
#
cd /tmp/
wget https://raw.githubusercontent.com/LIMXTEC/BTDX-Masternode-Setup/master/bitcloud.conf -O /tmp/bitcloud.conf
chown bitcloud:bitcloud /tmp/bitcloud.conf

#
# Set rpcuser, rpcpassword and masternode genkey
#
printf "** Set rpcuser, rpcpassword and masternode genkey ***\n"
mkdir -p /home/bitcloud/.bitcloud/
chown -R bitcloud:bitcloud /home/bitcloud/
sudo -u bitcloud cp /tmp/bitcloud.conf /home/bitcloud/.bitcloud/
sed -i "s|^\(rpcuser=\).*|rpcuser=btdxmasternode$(openssl rand -base64 32)|g" /home/bitcloud/.bitcloud/bitcloud.conf
sed -i "s|^\(rpcpassword=\).*|rpcpassword=$(openssl rand -base64 32)|g" /home/bitcloud/.bitcloud/bitcloud.conf
sed -i "s|^\(masternodeprivkey=\).*|masternodeprivkey=${MN_KEY}|g" /home/bitcloud/.bitcloud/bitcloud.conf
sed -i "s|^\(externalip=\).*|externalip=${BTDX_IP}|g" /home/bitcloud/.bitcloud/bitcloud.conf 
RPC_ALLOWIP=$(ip addr | grep 'global eth0' | xargs | cut -f2 -d ' ')
sed -i "s#^\(rpcallowip=\).*#rpcallowip=${RPC_ALLOWIP}#g" /home/bitcloud/.bitcloud/bitcloud.conf

#
# Downloading bootstrap file
#
printf "** Downloading bootstrap file ***\n"
cd /home/bitcloud/.bitcloud/
if [ ! -d /home/bitcloud/.bitcloud/blocks ] && [ "$(curl -Is https://${WEB}/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitcloud wget https://${WEB}/${BOOTSTRAP}; \
        sudo -u bitcloud tar -xvzf ${BOOTSTRAP}; \
        sudo -u bitcloud rm ${BOOTSTRAP}; \
fi

#
# Starting Bitcloud Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Starting Bitcloud Service ***\n"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
