#!/usr/bin/bash

mkdir -p uploads
wget -nv -O uploads/prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v2.40.7/prometheus-2.40.7.linux-amd64.tar.gz
if [ $? -ne 0 ]
then
  echo "Could not download prometheus"
  exit 1
fi
wget -nv -O uploads/prometheus-ecs-discovery-linux-amd64 https://github.com/teralytics/prometheus-ecs-discovery/releases/download/v1.4.1/prometheus-ecs-discovery-linux-amd64
if [ $? -ne 0 ]
then
  echo "Could not download prometheus ecs discoverer"
  exit 1
fi
