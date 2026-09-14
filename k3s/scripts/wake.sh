#!/bin/bash

export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/snap/bin
export KUBECONFIG=/home/admin/.kube/config

# Wait for Docker to respond after system wake
until docker info > /dev/null 2>&1; do
  sleep 2
done


# Start Cluster
sudo systemctl start k3s


# Wait for K3s API server and nodes to be ready
until kubectl get nodes > /dev/null 2>&1; do
  sleep 2
done

kubectl wait --for=condition=ready node --all --timeout=60s

# Check for pending deployment update
PENDING_FILE=/home/admin/k3s-cluster/k3s/scripts/pending-update
if [ -f "$PENDING_FILE" ] && grep -q "PENDING_UPDATE=true" "$PENDING_FILE"; then
  kubectl rollout restart deployment equities-bot commodities-bot -n trading
  kubectl rollout status deployment equities-bot -n trading --timeout=120s
  kubectl rollout status deployment commodities-bot -n trading --timeout=120s
  rm -f "$PENDING_FILE"
fi

# Scale up trading bots & redis cache
kubectl scale deployment equities-bot commodities-bot redis-cache -n trading --replicas=1
