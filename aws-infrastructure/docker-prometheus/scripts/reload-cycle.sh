#!/bin/bash

sleep 60

while true
do
  echo "Running Configuration download"
  /bin/bash /prometheus/bin/config-download.sh
  echo "Downloaded Configuration now sleep until next run"
  sleep 300
done

