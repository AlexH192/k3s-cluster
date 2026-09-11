#!/bin/bash

sudo systemctl start k3s
sleep 30
kubectl wait --for=condition=ready node --all --timeout=60s

# Check for pending deployment update
PENDING_FILE=~/k3s-cluster/k3s/scripts/pending-update
if [ -f "$PENDING_FILE" ] && grep -q "PENDING_UPDATE=true" "$PENDING_FILE"; then
  kubectl rollout restart deployment equities-bot -n trading
  kubectl rollout restart deployment commodities-bot -n trading
  kubectl rollout status deployment equities-bot -n trading --timeout=120s
  kubectl rollout status deployment commodities-bot -n trading --timeout=120s
  rm "$PENDING_FILE"
fi

# Scale up trading bots & redis cache
kubectl scale deployment equities-bot commodities-bot redis-cache -n trading --replicas=1
