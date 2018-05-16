#!/bin/bash
set -u

BOOTSTRAP='bootstrap.tar.gz'

#
# Set passwd of bitcloud user
#
echo bitcloud:${BTDXPWD} | chpasswd

#
# Set masternode genkey
#
printf "** Set masternode genkey ***"
mkdir -p /home/bitcloud/.bitcloud
chown -R bitcloud:bitcloud /home/bitcloud
sudo -u bitcloud cp /tmp/bitcloud.conf /home/bitcloud/.bitcloud/
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
