#!/bin/bash

# kill the collector
lsof -ti :9033 | xargs kill

# Stop and remove containers
docker stop collector prometheus grafana
docker rm collector prometheus grafana

# Remove network if it exists
NETWORK_NAME="squash-monitoring-network"
if docker network inspect "$NETWORK_NAME" &> /dev/null; then
    docker network rm "$NETWORK_NAME"
    echo "Network '$NETWORK_NAME' removed."
else
    echo "Network '$NETWORK_NAME' does not exist."
fi

echo "Monitoring stopped, cleanup done."
