#!/bin/bash
# Prepare Prometheus
cd /tmp/prometheus
tar -xzf prometheus*.tar.gz

mkdir -p /prometheus
mkdir -p /prometheus/bin
mkdir -p /prometheus/data
mkdir -p /prometheus/rules
mkdir -p /prometheus/config
mkdir -p /prometheus/download
mkdir -p /prometheus/logs
ln -s /prometheus/download/discovered.yml /prometheus/discovered.yml

DIR=$(ls | grep "prometheus.*amd64$")

cp ./$DIR/prometheus /prometheus/bin
cp -R ./$DIR/console_libraries /prometheus
cp -R ./$DIR/consoles /prometheus
cp ./$DIR/prometheus.yml /prometheus/config

rm -Rf *