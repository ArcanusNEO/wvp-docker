#!/bin/sh
set -ex
docker build -f Dockerfile.zl -t lucas/zlmediakit:0.1.0 .
docker pull mysql:latest
docker build -f Dockerfile.wvp -t lucas/wvp:0.1.0 .
docker run -itd --restart=always --name mysql-wvp --ip '172.17.0.254' -e MYSQL_ROOT_PASSWORD='123465' mysql:latest
docker run -itd --restart=always --name zlmediakit --ip '172.17.0.253' lucas/zlmediakit:0.1.0
docker run -itd --restart=always --name wvp -e MYSQL_HOST='172.17.0.254' -e MYSQL_PWD='123465' -e ZLM_HOST='172.17.0.253' -p 5060:5060 -p 18080:18080 lucas/wvp:0.1.0
