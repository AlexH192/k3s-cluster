#!/bin/bash

wakeonlan a4:bb:6d:23:e0:ae
sleep 30
kubectl wait --for=condition=ready node --all --timeout=60s

# Scale up trading bots & redis cache
kubectl scale deployment equities-bot commodities-bot redis-cache -n trading --replicas=1
