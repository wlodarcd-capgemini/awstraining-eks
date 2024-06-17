#!/bin/bash

# Setup password for kibana service user
./bin/elasticsearch-reset-password -u kibana_system -i changeme
echo "Changed password for kibana_system user"

# Start Elasticsearch
echo "Starting Elasticsearch..."
./bin/elasticsearch

