#!/bin/bash

trap "kill 0" SIGINT
trap "kill 0" EXIT

TOPICNAME="t1-stretched"

echo ">>> Consuming ${TOPICNAME}"
docker-compose exec broker-east-3 kafka-console-consumer --bootstrap-server broker-west-1:19091,broker-east-3:19093 --topic ${TOPICNAME} --property print.offset=true


