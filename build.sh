#!/bin/sh

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-123465}"
MYSQL_HOST=172.18.254.2
ZLM_HOST=172.18.254.3
docker network create -d bridge wvp-net --subnet=172.18.254.0/24 --gateway=172.18.254.1

set -ex
docker pull mysql:latest
docker run -d --restart=always --name=mysql-wvp -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD --network=wvp-net --ip=$MYSQL_HOST mysql:latest

docker build -f Dockerfile.zl -t lucas/zlmediakit:0.1.0 .
docker build -f Dockerfile.wvp -t lucas/wvp:0.1.0 .
docker run -d --restart=always --name=zlmediakit --network=wvp-net --ip=$ZLM_HOST lucas/zlmediakit:0.1.0

set +ex
echo "waiting for MySQL to be ready"
while
  docker run --rm --network=wvp-net mysql:latest mysql -h$MYSQL_HOST -uroot -p$MYSQL_ROOT_PASSWORD &>/dev/null
  [[ "$?"_ != "0"_ ]]
do
  echo -n '.'
  sleep 1
done
sleep 1 && echo "" && echo "MySQL is ready"

set -ex

echo 'CREATE DATABASE IF NOT EXISTS wvp DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;' | docker exec -i mysql-wvp mysql -ABq -uroot -p$MYSQL_ROOT_PASSWORD
curl -fsSL https://gitee.com/pan648540858/wvp-GB28181-pro/raw/wvp-28181-2.0/sql/mysql.sql | sed -E -e 's/wvp2/wvp/g' -e 's/\s\+\s00:00/UTC/g' | docker exec -i mysql-wvp mysql -ABq -uroot -p$MYSQL_ROOT_PASSWORD -Dwvp

docker run -d --restart=always --name=wvp --network=wvp-net -e MYSQL_HOST=$MYSQL_HOST -e MYSQL_PWD=$MYSQL_ROOT_PASSWORD -e ZLM_HOST=$ZLM_HOST -p 5060:5060 -p 5060:5060/udp -p 18080:18080 -p 80:80 -p 10000:10000 -p 10000:10000/udp -p 30000-30500:30000-30500 -p 30000-30500:30000-30500/udp lucas/wvp:0.1.0
