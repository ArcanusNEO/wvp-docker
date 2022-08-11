#!/bin/sh

./stop.sh
docker rm wvp
docker rm zlmediakit
docker rm mysql-wvp
docker network rm wvp-net
