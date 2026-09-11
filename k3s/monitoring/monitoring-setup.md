# Monitoring Setup

With the trading bot now running, monitoring processes can be added to ensure everything is running as intended. Prometheus, which was installed previously (via Helm installation) during the master node setup, can monitor system resource usage, Docker containers and more and display all information on the Headlamp UI. Grafana is also used for more visual monitoring tasks, while Alertmanager sends Telegram push notifications if the cluster crashes or experiences usage spikes.
<br><br>A new namespace, 'monitoring', will be created in order to separate monitoring processes from trading bot processes:
```
kubectl create namespace monitoring
```
## Prometheus Setup
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
## Headlamp & Grafana Setup
<br><br><br>Create a permanent Headlamp admin token (with this deployment, token resets every 24 hours):
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
<br><br>To make Prometheus and Headlamp visible persistently (as opposed to having to port forward every time to monitor), some modifications must be made.
<br><br>NodePort services must be created in order to be able to access the monitoring sites from anywhere.
<br>For Headlamp:
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
Find new network ports:
```
kubectl get svc -A | grep NodePort
```
The output should look like the image below:
<br><img width="1184" height="49" alt="image" src="https://github.com/user-attachments/assets/3e9054d1-bfa6-43f5-acad-636a14abc4a6" />
<br><br>Both Headlamp and Grafana can now be accessed via ports 30080 and 30081, respectively. To access them on a browser, use the address `http://<TAILSCALE_IP>:<PORT>`.
<br><br>In my case, Headlamp is accessed with `http://100.72.243.26:30080` and Grafana is accessed with `http://100.72.243.26:30081`.
## Grafana Configuration
To make sure Grafana is receiving data from the right sources, navigate to `Connections > Data Sources`. Prometheus should appear, as in the image below:
<img width="1438" height="530" alt="image" src="https://github.com/user-attachments/assets/6c8e4e08-5f5a-4344-969f-7b2da83f6518" />
<br><br>Import some dashboards by navigating to `Dashboards > New > Import Dashboards`
<br>Depending on which dashboards were imported, the Grafana monitoring interface should look something like this:
<img width="1434" height="775" alt="image" src="https://github.com/user-attachments/assets/770f77c1-5e2a-46a1-a4bc-d5e1230ca2a0" />



## Alertmanager Setup
To set up Alertmanager, a config must be created with the Telegram credentials (stored as a secret):
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-config
  namespace: monitoring
stringData:
  alertmanager.yaml: |
    global:
      resolve_timeout: 5m

    route:
      group_by: ['alertname', 'namespace']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      receiver: telegram
      routes:
      - matchers:
        - alertname = Watchdog
        receiver: null-receiver
      - matchers:
        - alertname = KubeProxyDown
        receiver: null-receiver

    receivers:
    - name: telegram
      telegram_configs:
      - bot_token: <TELEGRAM_BOT_TOKEN>
        chat_id: <TELEGRAM_CHAT_ID>
        message: |
          *{{ .GroupLabels.alertname }}*
          {{ range .Alerts }}
          *Status:* {{ .Status }}
          *Namespace:* {{ .Labels.namespace }}
          *Pod:* {{ .Labels.pod }}
          *Message:* {{ .Annotations.message }}
          {{ end }}
        parse_mode: Markdown
    - name: null-receiver
EOF
```
Update Prometheus helm to use the config:
```
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --reuse-values \
  --set alertmanager.alertmanagerSpec.configSecret=alertmanager-config
```
Create Alertmanager alert rules that dictate when a notification is sent -- I chose the most severe cases (crashes, crash looping, high usage, node outages):
```
kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: bot-alerts
  namespace: monitoring
  labels:
    release: prometheus
spec:
  groups:
  - name: trading-bot
    rules:
    - alert: TradingBotDown
      expr: kube_deployment_status_replicas_available{namespace="trading"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        message: "Trading bot {{ \$labels.deployment }} is down in namespace {{ \$labels.namespace }}"

    - alert: TradingBotRestarting
      expr: rate(kube_pod_container_status_restarts_total{namespace="trading"}[15m]) > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        message: "Pod {{ \$labels.pod }} is restarting frequently"

  - name: cluster
    rules:
    - alert: NodeMemoryHigh
      expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.85
      for: 5m
      labels:
        severity: warning
      annotations:
        message: "Node memory usage is above 85%"

    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        message: "Pod {{ \$labels.pod }} in {{ \$labels.namespace }} is crash looping"

    - alert: NodeDown
      expr: up{job="node-exporter"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        message: "Node {{ \$labels.instance }} is down"
EOF
```
Execute a rollout restart for Alertmanager:
```
kubectl rollout status statefulset alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring
```
Test Alertmanager by scaling down one of the trading bot processes:
```
kubectl scale deployment equities-bot -n trading --replicas=0
```
A Telegram message should be sent and look like this:
<br><img width="463" height="152" alt="image" src="https://github.com/user-attachments/assets/17706598-1fdf-4d79-aaa0-ee6b45556385" />
<br><br>When an issue is resolved, another message with `Status: resolved` is sent:
<br><img width="459" height="153" alt="image" src="https://github.com/user-attachments/assets/9b74776a-ec84-4f4e-87b3-1b4e59437006" />
