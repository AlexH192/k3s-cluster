# Monitoring Setup

With the trading bot now running, monitoring processes can be added to ensure everything is running as intended. Prometheus, which was installed previously during the master node setup, can monitor system resource usage, Docker containers and more and display all information on the Headlamp UI.
<br><br>A new namespace, 'monitoring', will be created in order to separate monitoring processes from trading bot processes:
```
kubectl create namespace monitoring
```
Add Prometheus Helm repository and update:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
Deploy Prometheus into the 'monitoring' namespace:
```
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set alertmanager.enabled=false \
  --set pushgateway.enabled=false \
  --set server.persistentVolume.size=8Gi
```
Confirm the installation:
```
kubectl get pods -n monitoring -o wide
```
`prometheus-node-exporter` should be running on each node, as shown below:
<img width="1028" height="119" alt="image" src="https://github.com/user-attachments/assets/55cee9ce-9aba-4734-8b54-33adf3ec4177" />
