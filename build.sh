#!/bin/sh
set -ex
docker build -f Dockerfile.zl -t lucas/zlmediakit:0.1.0 .
docker pull mysql:latest
docker build -f Dockerfile.wvp -t lucas/wvp:0.1.0 .

docker run -itd --restart=always --name mysql-wvp -e MYSQL_ROOT_PASSWORD=123465 mysql:latest
docker run -itd --restart=always --name zlmediakit lucas/zlmediakit:0.1.0
docker run -itd --restart=always --name wvp -e MYSQL_HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mysql-wvp) -e MYSQL_PWD=123465 -e ZLM_HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' zlmediakit) -p 5060:5060 -p 5060:5060/udp -p 18080:18080 -p 80:80 -p 10000:10000 -p 10000:10000/udp -p 30000-30500:30000-30500 -p 30000-30500:30000-30500/udp lucas/wvp:0.1.0
