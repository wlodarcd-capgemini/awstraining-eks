#!/bin/bash

echo "Download Prometheus Config from Bucket ${CONFIG_BUCKET}"
# Copy Prometheus Config from S3
aws --region ${AWS_REGION} s3 cp s3://${CONFIG_BUCKET} /prometheus/download --recursive
if [ $? -ne 0 ]
then
  echo "Download Prometheus Config from Bucket failed"
  exit 1
fi

# Move Prometheus Config file to config dir
mv -f /prometheus/download/prometheus/prometheus.yml /prometheus/config/prometheus.yml

# Move alerts to final destination
mv -f /prometheus/download/prometheus/rules/* /prometheus/rules

# Trigger reload of Prometheus Config (SIGHUP)
PROM_PID=$(pgrep -f '^/prometheus/bin/prometheus')

if [ -n "$PROM_PID" ]
then
  echo "Triggering Prometheus Reload of PID ${PROM_PID}"
  kill -1 $PROM_PID
fi

