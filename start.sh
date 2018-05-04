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
mkdir -p /home/bitcloud/.bitcloud
chown -R bitcloud:bitcloud /home/bitcloud
sudo -u bitcloud cp /tmp/bitcloud.conf /home/bitcloud/.bitcloud/
sed -i "s/^\(masternodeprivkey=\).*/\masternodeprivkey=${MN_KEY}/" /home/bitcloud/.bitcloud/bitcloud.conf

#
# Step 8/10 - Downloading bootstrap file
#
printf "** Step 8/10 - Downloading bootstrap file ***"
cd /home/bitcloud/.bitcloud/
if if [ ! -d /home/bitcloud/.bitcloud/blocks ] && [ "$(curl -Is https://bit-cloud.info/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitcloud wget  https://bit-cloud.info/${BOOTSTRAP}; \
        sudo -u bitcloud tar -xvzf ${BOOTSTRAP}; \
fi
printf "*** Done 8/10 ***"

#
# Step 9/10 - Starting BitCloud Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Step 9/10 - Starting BitCloud Service ***\n"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
