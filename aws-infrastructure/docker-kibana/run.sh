#!/bin/bash

# Create Kibana service user in Elasticsearch
echo "Creating Kibana service user"
# Set the URL and data for your curl command
URL="https://localhost:9200/_security/user/kibana_system/_password"
DATA='{"password":"changeme"}'

set -x

# Function to send the curl command
send_curl() {
    echo "Sending first CURL"
    curl -vk -X POST -u "elastic:changeme" -H "Content-Type: application/json" -d "$DATA" "$URL" --connect-timeout 10.0 --max-time 10.0
    echo "Getting response"
    response=$(curl -vk -s -o /dev/null -w "%{http_code}" -X POST -u "elastic:changeme" -H "Content-Type: application/json" -d "$DATA" "$URL" --connect-timeout 10.0 --max-time 10.0)
    echo "HTTP Response Code: $response"

    if [ "$response" -eq 200 ]; then
        echo "HTTP status is 200 (OK). Exiting."
    else
        echo "Retrying in 5 seconds..."
        sleep 5
        send_curl
    fi
}

# Initial attempt
send_curl

echo "Done creating service user"

# Start Kibana
./bin/kibana