#!/bin/bash

# Silence trading bot alerts for 2 mins before scaling down
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093 &
PF_PID=$!
sleep 3

curl -s -X POST http://localhost:9093/api/v2/silences \
  -H "Content-Type: application/json" \
  -d '{
    "matchers": [
      {"name": "namespace", "value": "trading", "isRegex": false}
    ],
    "startsAt": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
    "endsAt": "'$(date -u -d "+2 minutes" +%Y-%m-%dT%H:%M:%SZ)'",
    "createdBy": "sleep-script",
    "comment": "Intentional shutdown"
  }'

kill $PF_PID

# Scale down processes and suspend system
kubectl scale deployment equities-bot commodities-bot redis-cache -n trading --replicas=0
k3d cluster stop wyse-5070
sudo systemctl suspend
