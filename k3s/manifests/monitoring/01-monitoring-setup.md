# Monitoring Setup

With the trading bot now running, monitoring processes can be added to ensure everything is running as intended. Prometheus, which was installed previously (via Helm installation) during the master node setup, can monitor system resource usage, Docker containers and more and display all information on the Headlamp UI. Grafana is also used for more visual monitoring tasks.
<br><br>A new namespace, 'monitoring', will be created in order to separate monitoring processes from trading bot processes:
```
kubectl create namespace monitoring
```
Add Prometheus Helm repository and update:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
Deploy Prometheus into the 'monitoring' namespace (and set the Grafana password):
```
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set alertmanager.enabled=false \
  --set pushgateway.enabled=false \
  --set server.persistentVolume.size=8Gi
  --set grafana.adminPassword=<PASSWORD>
```
Confirm the installation:
```
kubectl get pods -n monitoring -o wide
```
`prometheus-node-exporter` should be running on each node, as shown below:
<br><img width="1028" height="119" alt="image" src="https://github.com/user-attachments/assets/55cee9ce-9aba-4734-8b54-33adf3ec4177" />
<br><br>To make Prometheus and Headlamp visible persistently (as opposed to having to port forward every time to monitor), some modifications must be made. First, patch the Prometheus service to expose it on all physical node IPs:
```
kubectl patch svc prometheus-server -n monitoring -p '{"spec": {"type": "NodePort"}}'
```
Do the same for Headlamp:
```
kubectl patch svc my-headlamp -n kube-system -p '{"spec": {"type": "NodePort"}}'
```
Find new network ports:
```
kubectl get svc -A | grep -E "prometheus-server|headlamp"
```
The output should look like the image below:
<br><img width="927" height="75" alt="image" src="https://github.com/user-attachments/assets/c2d328a8-39f5-47c9-b653-398216c3f618" />
<br>Create a permanent Headlamp admin token (with this deployment, token resets every 24 hours):
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: headlamp-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: headlamp-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: headlamp-admin
  namespace: kube-system
---
apiVersion: v1
kind: Secret
metadata:
  name: headlamp-admin-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: headlamp-admin
type: kubernetes.io/service-account-token
EOF
```
Retrieve the token:
```
kubectl get secret headlamp-admin-token -n kube-system -o jsonpath="{.data.token}" | base64 --decode
```
NodePort services must be created in order to be able to access the monitoring sites from anywhere.
<br><br>For Headlamp:
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: headlamp-nodeport
  namespace: kube-system
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: headlamp
  ports:
  - port: 80
    targetPort: 4466
    nodePort: 30080
EOF
```
For Grafana:
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: grafana-nodeport
  namespace: monitoring
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: grafana
  ports:
  - port: 80
    targetPort: 3000
    nodePort: 30081
EOF
```
Both Headlamp and Grafana can now be accessed via ports 30080 and 30081, respectively. To access them on a browser, use the address `http://<TAILSCALE_IP>:<PORT>`.
<br><br>In my case, Headlamp is accessed with `http://100.72.243.26:30080` and Grafana is accessed with `http://100.72.243.26:30081`.
