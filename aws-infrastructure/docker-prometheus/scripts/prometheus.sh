#!/bin/sh

#mkdir -p /prometheus/download
#mkdir -p /prometheus/data
#mkdir -p /prometheus/config
#mkdir -p /prometheus/rules

#echo "Downloading Configuration for Prometheus"
#/bin/sh /prometheus/bin/config-download.sh

# Starting service-discovery in background
/prometheus/bin/service-discovery.sh &

# Starting reload-cycle in background
#/prometheus/bin/reload-cycle.sh &

if [ "x$NO_ECS_DISCOVERY" == "x" ]
then
  echo "Wait 10s for initial ECS discovery..."
  sleep 10
fi

echo "Starting Prometheus"
/prometheus/bin/prometheus \
    --config.file=/prometheus/config/prometheus.yml \
    --storage.tsdb.path=/prometheus/data  \
    --web.console.libraries=/prometheus/console_libraries \
    --web.console.templates=/prometheus/consoles 2>&1

