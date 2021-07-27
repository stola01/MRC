#!/bin/bash


for CONTAINERNAME in broker-west-1 broker-west-2 broker-east-3 broker-east-4 broker-west-5 broker-east-6
do
	IPADDR=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINERNAME})
	echo ${IPADDR} ${CONTAINERNAME}
done
