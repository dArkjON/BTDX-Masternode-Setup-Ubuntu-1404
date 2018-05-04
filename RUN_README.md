# Bitcloud (BTDX) Masternode - Run Docker Image

## Adding firewall rules
Open needed ports on your docker host server.
```
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8329/tcp
ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable
```

## Pull docker image
```
docker pull <repository>/btdx-masternode
```

## Run docker container
```
docker run -p 8886:8886 -p 8800:8800 --name btdx-masternode -e BTDXPWD='NEW_BTDX_PWD' -e MN_KEY='YOUR_MN_KEY' -v /home/bitcloud:/home/bitcloud:rw -d <repository>/bsd-masternode
docker ps
```

## Debbuging within a container (after start.sh execution)
Please execute ```docker run``` without option ```--entrypoint bash``` before you execute this commands:
```
tail -f /home/bitcloud/.bitcloud/debug.log

docker ps
docker exec -it btdx-masternode bash
  # you are inside the btx-rpc-server container
  root@container# supervisorctl status bitcloudd
  root@container# cat /var/log/supervisor/supervisord.log
  # Change to bitcloud user
  root@container# sudo su bitcloud
  bitcloud@container# cat /home/bitcloud/.bitcloud/debug.log
  bitcloud@container# bitcloud-cli getinfo
```

## Debbuging within a container during run (skip start.sh execution)
```
docker run -p 8886:8886 -p 8800:8800 --name btdx-masternode -e BTDXPWD='NEW_BTDX_PWD' -e MN_KEY='YOUR_MN_KEY' -v /home/bitcloud:/home/bitcloud:rw --entrypoint bash <repository>/btdx-masternode
```

## Stop docker container
```
docker stop btdx-masternode
docker rm btdx-masternode
```
