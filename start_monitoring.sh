#!/bin/bash
set -e

# ---------------------------------------------------------------------------------------------
# Download latest images first
# 1. docker pull otel/opentelemetry-collector
# 2. docker pull prom/prometheus
# 3. docker pull grafana/grafana
#
# To connect grafana to prometheus, go to the ui
# http://localhoost:3000
#
# Follow this guide:
# https://grafana.com/docs/grafana/latest/datasources/prometheus/configure-prometheus-data-source/ 
#
# Use this address from the docker internal network:
# http://prometheus:9090
#
# To stop all moniotoring tools: docker stop $(docker ps -q)
# ---------------------------------------------------------------------------------------------


NETWORK_NAME="squash-monitoring-network"

# Check if the network exists
if ! docker network inspect "$NETWORK_NAME" &> /dev/null; then
    # Network does not exist, create it
    docker network create "$NETWORK_NAME"
    echo "Network '$NETWORK_NAME' created."
else
    echo "Network '$NETWORK_NAME' already exists."
fi

echo "Starting OTEL Collector on port 4318"
docker run -d --name collector --network $NETWORK_NAME -p 4318:4318 -v /home/chris/dev/AutoSquash/templates/SquashTM/conf/collector-config.yaml otel/opentelemetry-collector:latest > otel_collector.log 2>&1

echo "Starting Prometheus on port 9090"
docker run -d --name prometheus --network $NETWORK_NAME -p 9090:9090 -v /home/chris/dev/AutoSquash/templates/SquashTM/conf/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus > prometheus.log 2>&1

echo "Starting Grafana on port 3000"
docker run -d --name grafana --network $NETWORK_NAME -p 3000:3000 grafana/grafana-enterprise > grafana.log 2>&1

echo "Goto Grafana on http://localhost:3000"
