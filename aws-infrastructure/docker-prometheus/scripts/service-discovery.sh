#!/bin/bash

if [ "x$NO_ECS_DISCOVERY" != "x" ]
then
  echo "ECS service discovery is disabled"
  exit 0
fi

echo "Starting Service Discovery with Filter ${DISCOVERY_FILTER}"

while true
do
	/prometheus/bin/prometheus-ecs-discovery-linux-amd64 -config.write-to /prometheus/download/discovered.yml \
	 -config.scrape-interval 1m0s \
	 -config.scrape-times 1 \
	 -config.filter-label ${DISCOVERY_FILTER} 2>&1
	 sleep 55
done
