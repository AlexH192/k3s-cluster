#!/bin/bash
echo "Cluster Health Check"

echo ""
echo "Nodes:"
kubectl get nodes

echo ""
echo "Trading Pods:"
kubectl get pods -n trading

echo ""
echo "Monitoring Pods:"
kubectl get pods -n monitoring

echo ""
echo "Failed/Pending Pods:"
kubectl get pods -A | grep -v Running | grep -v Completed

echo ""
echo "Resource Usage:"
kubectl top nodes 2>/dev/null || echo "Metrics server not ready"

echo ""
echo "Trading Bot Logs (last 10 lines each):"
echo "Equities Bot;"
kubectl logs -n trading -l app=equities-bot --tail=10 2>/dev/null

echo ""
echo "Commodities Bot:"
kubectl logs -n trading -l app=commodities-bot --tail=10 2>/dev/null

echo ""
echo "Health Check Complete"
