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
#
#
# Currently config files under squash... should be independent
# ---------------------------------------------------------------------------------------------

CONF_DIR=/home/chris/dev/AutoSquash/templates/SquashTM/conf
BUNDLES_DIR=/home/chris/dev/AutoSquash/SquashTM_work/squash-tm/bundles 

NETWORK_NAME="host"

echo "Starting Prometheus on port 9090"
docker run -d --name prometheus --network $NETWORK_NAME -p 9090:9090 -v ${CONF_DIR}/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus  > prometheus.log 2>&1

echo "Starting Grafana on port 3000"
docker run -d --name grafana --network $NETWORK_NAME -p 3000:3000 grafana/grafana-enterprise > grafana.log 2>&1

echo "Goto Grafana on http://localhost:3000"
