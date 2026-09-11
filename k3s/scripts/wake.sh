#!/bin/bash

sudo systemctl start k3s
sleep 30
kubectl wait --for=condition=ready node --all --timeout=60s

# Scale up trading bots & redis cache
kubectl scale deployment equities-bot commodities-bot redis-cache -n trading --replicas=1
