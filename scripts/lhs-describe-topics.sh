#!/bin/bash

clear

for TOPICNAME in t1-stretched t1-stretched-with-observers
do
  echo
  echo
  echo
  echo -e "\n==> Describe topic: ${TOPICNAME}\n"

  docker-compose exec broker-east-3 kafka-topics --describe --bootstrap-server broker-east-3:19093 --topic ${TOPICNAME}

done
