#!/bin/bash
COIN_CHAIN='https://node-support.network/bootstrap/bitcloud-blockchain.tar.gz'

mkdir /root/btdx_temp >/dev/null 2>&1
cd /root/btdx_temp >/dev/null 2>&1
echo -e "Downloading and extracting BitCloud blockchain files."
wget -q $COIN_CHAIN
tar -xzvf bitcloud-blockchain.tar.gz -C /root/btdx_temp >/dev/null 2>&1
rm -rf /root/.bitcloud/blocks >/dev/null 2>&1
rm -rf /root/.bitcloud/chainstate >/dev/null 2>&1
mv /root/btdx_temp/root/Bootstrap/.bitcloud/blocks /root/.bitcloud >/dev/null 2>&1
mv /root/btdx_temp/root/Bootstrap/.bitcloud/chainstate /root/.bitcloud >/dev/null 2>&1
cd ~
rm -R /root/btdx_temp >/dev/null 2>&1
