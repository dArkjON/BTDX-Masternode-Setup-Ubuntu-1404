#!/bin/bash
set -u

BOOTSTRAP='bootstrap.tar.gz'

#
# Set passwd of bitcloud user
#
echo bitcloud:${BTDXPWD} | chpasswd

#
# Set rpcuser, rpcpassword and masternode genkey
#
printf "** Set rpcuser, rpcpassword and masternode genkey ***"
mkdir -p /home/bitcloud/.bitcloud
chown -R bitcloud:bitcloud /home/bitcloud
sudo -u bitcloud cp /tmp/bitcloud.conf /home/bitcloud/.bitcloud/
sed -i "s/^\(rpcuser=\).*/\rpcuser=btdxmasternode$(openssl rand -base64 32)/" /home/bitcloud/.bitcloud/bitcloud.conf
sed -i "s/^\(rpcpassword=\).*/\rpcpassword=$(openssl rand -base64 32)/" /home/bitcloud/.bitcloud/bitcloud.conf
sed -i "s/^\(masternodeprivkey=\).*/\masternodeprivkey=${MN_KEY}/" /home/bitcloud/.bitcloud/bitcloud.conf

#
# Downloading bootstrap file
#
printf "** Downloading bootstrap file ***"
cd /home/bitcloud/.bitcloud/
if [ ! -d /home/bitcloud/.bitcloud/blocks ] && [ "$(curl -Is https://bit-cloud.info/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitcloud wget  https://bit-cloud.info/${BOOTSTRAP}; \
        sudo -u bitcloud tar -xvzf ${BOOTSTRAP}; \
        sudo -u bitcloud rm ${BOOTSTRAP}; \
fi

#
# Starting Bitcloud Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Starting Bitcloud Service ***"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
