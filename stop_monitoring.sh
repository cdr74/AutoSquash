#!/bin/bash


# Stop and remove containers
docker stop  prometheus grafana
docker rm  prometheus grafana

echo "Monitoring stopped, cleanup done."
