#!/bin/bash


TOPICNAME="t1-stretched"
echo -e "\n==> Creating topic ${TOPICNAME}"
docker-compose exec broker-west-1 kafka-topics  --create \
	--bootstrap-server broker-west-1:19091 \
	--topic ${TOPICNAME} \
	--partitions 1 \
	--replica-placement /etc/kafka/demo/lhs-placement-mrc-stretched.json \
	--config min.insync.replicas=3

TOPICNAME="t1-stretched-with-observers"
echo -e "\n==> Creating topic ${TOPICNAME}"
docker-compose exec broker-west-1 kafka-topics  --create \
	--bootstrap-server broker-west-1:19091 \
	--topic ${TOPICNAME} \
	--partitions 1 \
	--replica-placement /etc/kafka/demo/lhs-placement-mrc-stretched-with-observers.json \
	--config min.insync.replicas=3

