#!/bin/sh
set -ex
docker build -f Dockerfile.zl -t lucas/zlmediakit:0.1.0 .
docker pull mysql:latest
docker build -f Dockerfile.wvp -t lucas/wvp:0.1.0 .

docker run -itd --restart=always --name mysql-wvp -e MYSQL_ROOT_PASSWORD=123465 mysql:latest
docker run -itd --restart=always --name zlmediakit lucas/zlmediakit:0.1.0
docker run -itd --restart=always --name wvp -e MYSQL_HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mysql-wvp) -e MYSQL_PWD=123465 -e ZLM_HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' zlmediakit) -p 5060:5060 -p 18080:18080 lucas/wvp:0.1.0
