#!/bin/sh
set -ex

MYSQL_ROOT_PASSWORD=123465
docker pull mysql:latest
docker run -d --restart=always --name mysql-wvp -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD --health-cmd='mysqladmin ping --silent' mysql:latest

docker build -f Dockerfile.zl -t lucas/zlmediakit:0.1.0 .
docker build -f Dockerfile.wvp -t lucas/wvp:0.1.0 .
docker run -d --restart=always --name zlmediakit lucas/zlmediakit:0.1.0

while
  MYSQL_STATUS=$(docker inspect --format "{{.State.Health.Status}}" mysql-wvp)
  [ $MYSQL_STATUS != "healthy" ]
do
  if [ $STATUS == "unhealthy" ]; then
    echo "MySQL failed to start!"
    exit -1
  fi
  printf .
  sleep 1
done
sleep 1 && echo ""
echo 'CREATE DATABASE IF NOT EXISTS wvp DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;' | docker exec -i mysql-wvp mysql -ABq -uroot -p$MYSQL_ROOT_PASSWORD
curl -fsSL https://gitee.com/pan648540858/wvp-GB28181-pro/raw/wvp-28181-2.0/sql/mysql.sql | sed -E -e 's/wvp2/wvp/g' -e 's/\s\+\s00:00/UTC/g' | docker exec -i mysql-wvp mysql -ABq -uroot -p$MYSQL_ROOT_PASSWORD -Dwvp

docker run -d --restart=always --name wvp -e MYSQL_HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mysql-wvp) -e MYSQL_PWD=$MYSQL_ROOT_PASSWORD -e ZLM_HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' zlmediakit) -p 5060:5060 -p 5060:5060/udp -p 18080:18080 -p 80:80 -p 10000:10000 -p 10000:10000/udp -p 30000-30500:30000-30500 -p 30000-30500:30000-30500/udp lucas/wvp:0.1.0
