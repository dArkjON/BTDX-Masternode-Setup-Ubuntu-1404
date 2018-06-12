# Bitcloud (BTDX) Masternode - Run Docker Image

## Adding firewall rules
Open needed ports on your docker host server.
```
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8329/tcp
ufw allow 8330/tcp
ufw allow 9050/tcp
ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable
```

## Pull docker image
```
docker pull limxtec/btdx-masternode
```

## Run docker container
```
docker run -p 8329:8329 -p 8330:8330 -p 9050:9050 --name btdx-masternode -e BTDXPWD='NEW_BTDX_PWD' -e MN_KEY='YOUR_MN_KEY' -v /home/bitcloud:/home/bitcloud:rw -d limxtec/btdx-masternode
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
docker run -p 8329:8329 -p 8330:8330 -p 9050:9050 --name btdx-masternode -e BTDXPWD='NEW_BTDX_PWD' -e MN_KEY='YOUR_MN_KEY' -v /home/bitcloud:/home/bitcloud:rw --entrypoint bash limxtec/btdx-masternode
```

## Stop docker container
```
docker stop btdx-masternode
docker rm btdx-masternode
```
