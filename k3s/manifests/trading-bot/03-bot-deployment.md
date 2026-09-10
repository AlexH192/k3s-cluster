# Bot Deployment

Similar to Redis, the trading bot itself also needs a deployment YAML file. This is done below.
<br><br>To create the file, run:
```
nano bot-deployment.yaml
```
The file is provided as `/k3s/manifests/trading-bot/bot-deployment.yaml`.
<br><br>Apply the file by running:
```
kubectl apply -f bot-deployment.yaml
```
